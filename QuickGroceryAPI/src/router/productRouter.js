import { Router } from 'express';
import { products } from '../models/Product.js';
import { fail, serialize } from '../utils/http.js';

const router = Router();

const normalize = (value) => String(value || '')
  .normalize('NFKD')
  .replace(/[\u0300-\u036f]/g, '')
  .toLocaleLowerCase()
  .replace(/[^\p{L}\p{N}]+/gu, ' ')
  .trim();

function withinEditDistance(left, right, limit) {
  if (Math.abs(left.length - right.length) > limit) return false;
  let previous = Array.from({ length: right.length + 1 }, (_, i) => i);
  for (let i = 1; i <= left.length; i += 1) {
    const current = [i];
    let rowMin = i;
    for (let j = 1; j <= right.length; j += 1) {
      current[j] = Math.min(current[j - 1] + 1, previous[j] + 1, previous[j - 1] + (left[i - 1] === right[j - 1] ? 0 : 1));
      rowMin = Math.min(rowMin, current[j]);
    }
    if (rowMin > limit) return false;
    previous = current;
  }
  return previous[right.length] <= limit;
}

function matchesSearch(product, search) {
  if (!search) return true;
  const fields = [product.name, product.brand, product.category, product.description, ...(product.aliases || [])]
    .map(normalize).filter(Boolean);
  const words = fields.flatMap((field) => field.split(' '));
  return search.split(' ').every((queryWord) => fields.some((field) => field.includes(queryWord)) || words.some((word) => {
    if (queryWord.length < 4 || word.length < 4) return false;
    return withinEditDistance(queryWord, word, queryWord.length > 7 ? 2 : 1);
  }));
}

router.get('/', async (req, res, next) => {
  try {
    const search = normalize(req.query.search);
    const category = String(req.query.category || '').trim();
    const available = req.query.available === 'true';
    const snapshot = await products.get();
    const productRecords = snapshot.docs.map(serialize).filter((product) => {
      const matches = matchesSearch(product, search);
      return matches && (!category || product.category === category) && (!available || Number(product.stock) > 0) && product.active !== false;
    }).sort((a, b) => String(a.name).localeCompare(String(b.name)));
    res.json(productRecords);
  } catch (error) { next(error); }
});

router.get('/:id', async (req, res, next) => {
  try {
    const snapshot = await products.doc(req.params.id).get();
    if (!snapshot.exists || snapshot.data()?.active === false) throw fail(404, 'Product not found.');
    res.json(serialize(snapshot));
  } catch (error) { next(error); }
});

export default router;
