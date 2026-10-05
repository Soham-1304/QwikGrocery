import 'dotenv/config';
import './config/db.js';
import app from './app.js';
import { processDueSchedules } from './services/scheduleRunner.js';
import { resumeActiveOrderLifecycles } from './services/orderLifecycle.js';

const port = Number(process.env.PORT || 3000);
app.listen(port, () => {
  console.log(`QwikGrocery API listening on port ${port}`);
  resumeActiveOrderLifecycles().catch((error) =>
    console.error('Initial resume of active orders failed:', error)
  );
});

setInterval(
  () =>
    processDueSchedules().catch((error) =>
      console.error('Recurring order run failed:', error)
    ),
  30_000
);

setInterval(
  () =>
    resumeActiveOrderLifecycles().catch((error) =>
      console.error('Periodic order lifecycle check failed:', error)
    ),
  60_000
);
