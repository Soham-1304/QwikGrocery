import 'dotenv/config';
import './config/db.js';
import app from './app.js';

const port = Number(process.env.PORT || 3000);
app.listen(port, () => console.log(`QuickGrocery API listening on port ${port}`));
