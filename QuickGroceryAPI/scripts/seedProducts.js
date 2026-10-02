import 'dotenv/config';
import { createRequire } from 'node:module';
import { cert, initializeApp } from 'firebase-admin/app';
import { FieldValue, getFirestore } from 'firebase-admin/firestore';
import catalog from '../data/catalog.seed.json' with { type: 'json' };

const projectId = process.env.FIREBASE_PROJECT_ID;
if (!projectId) throw new Error('FIREBASE_PROJECT_ID is required.');
const overwrite = process.argv.includes('--overwrite');
const require = createRequire(import.meta.url);
const serviceAccountKey = require('../secrets/ServiceAccountKey.json');
initializeApp({ credential: cert(serviceAccountKey), projectId });
const db = getFirestore();
const starterProductIds = [
  'fruit_banana_1kg', 'fruit_apple_4pcs', 'veg_tomato_500g', 'veg_potato_1kg',
  'dairy_milk_1l', 'dairy_curd_500g', 'dairy_paneer_200g', 'dairy_eggs_6',
  'bakery_bread_400g', 'bakery_buns_4', 'bakery_croissant_2', 'bakery_pav_6',
  'pantry_rice_5kg', 'pantry_atta_5kg', 'pantry_toor_dal_1kg', 'pantry_oil_1l',
  'snack_makhana_100g', 'snack_peanuts_200g', 'snack_chips_150g', 'snack_biscuits_250g',
  'drink_orange_juice_1l', 'drink_water_1l', 'drink_tea_250g', 'drink_coffee_100g',
  'home_dishwash_500ml', 'home_detergent_1kg', 'home_tissue_6rolls', 'home_garbage_bags_30',
];

for (const product of catalog) {
  if (!product.id || !product.name || !product.brand || !product.category || !Number.isInteger(product.priceCents) || product.priceCents < 0 || !Number.isInteger(product.stock) || product.stock < 0 || !product.imageUrl.startsWith('https://') || !product.sourceUrl.startsWith('https://') || !Array.isArray(product.aliases)) {
    throw new Error(`Invalid catalog record: ${product.id || '(missing id)'}`);
  }
}

let added = 0;
let skipped = 0;
let updated = 0;
for (let offset = 0; offset < catalog.length; offset += 450) {
  const products = catalog.slice(offset, offset + 450);
  const refs = products.map(({ id }) => db.collection('products').doc(id));
  const existing = await db.getAll(...refs);
  const batch = db.batch();
  let batchAdded = 0;
  let batchUpdated = 0;
  for (const [index, { id, ...fields }] of products.entries()) {
    const ref = refs[index];
    if (existing[index].exists && !overwrite) {
      skipped += 1;
      continue;
    }
    if (overwrite) {
      batch.set(ref, { ...fields, active: true, priceSource: 'BigBasket listing snapshot checked 2026-10-02; prices vary by location and date.', stockSource: 'Initial demo inventory; replace with live inventory before launch.', updatedAt: FieldValue.serverTimestamp() }, { merge: true });
      if (existing[index].exists) batchUpdated += 1;
      else batchAdded += 1;
    } else {
      batch.create(ref, { ...fields, active: true, priceSource: 'BigBasket listing snapshot checked 2026-10-02; prices vary by location and date.', stockSource: 'Initial demo inventory; replace with live inventory before launch.', createdAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp() });
      batchAdded += 1;
    }
  }
  if (batchAdded || batchUpdated) await batch.commit();
  added += batchAdded;
  updated += batchUpdated;
}

// Retire only the first generic, Unsplash-based sample catalog created by this app.
// Keep those documents for any historical order references, but hide them from browsing.
for (let offset = 0; offset < starterProductIds.length; offset += 450) {
  const refs = starterProductIds.slice(offset, offset + 450).map((id) => db.collection('products').doc(id));
  const existing = await db.getAll(...refs);
  const batch = db.batch();
  let retired = 0;
  existing.forEach((snapshot, index) => {
    if (snapshot.exists && snapshot.data()?.active !== false) {
      batch.set(refs[index], { active: false, updatedAt: FieldValue.serverTimestamp() }, { merge: true });
      retired += 1;
    }
  });
  if (retired) await batch.commit();
}

const counts = catalog.reduce((result, product) => {
  result[product.category] = (result[product.category] || 0) + 1;
  return result;
}, {});
console.log(`Added ${added} catalog products; updated ${updated}; skipped ${skipped} existing records across ${Object.keys(counts).length} categories.`);
if (overwrite) console.log('Overwrite mode refreshed catalog fields from the seed file, including price and stock values.');
for (const [category, count] of Object.entries(counts)) console.log(`${category}: ${count}`);
