const IST_MINUTES = 330;

export function scheduledInstant(date, time) {
  const [year, month, day] = date.split('-').map(Number);
  const [hour, minute] = time.split(':').map(Number);
  return new Date(Date.UTC(year, month - 1, day, hour, minute - IST_MINUTES));
}

function nextDate(dateString, frequency) {
  const [year, month, day] = dateString.split('-').map(Number);
  if (frequency === 'Monthly') {
    const nextMonth = month === 12 ? 1 : month + 1;
    const nextYear = month === 12 ? year + 1 : year;
    const lastDay = new Date(Date.UTC(nextYear, nextMonth, 0)).getUTCDate();
    return `${nextYear}-${String(nextMonth).padStart(2, '0')}-${String(Math.min(day, lastDay)).padStart(2, '0')}`;
  }
  const days = frequency === 'Daily' ? 1 : frequency === 'Biweekly' ? 14 : 7;
  const next = new Date(Date.UTC(year, month - 1, day + days));
  return next.toISOString().slice(0, 10);
}

export function nextOccurrence({ scheduleDate, frequency, deliveryTime, after = new Date() }) {
  let date = scheduleDate;
  let instant = scheduledInstant(date, deliveryTime);
  for (let attempt = 0; instant <= after && attempt < 800; attempt += 1) {
    date = nextDate(date, frequency);
    instant = scheduledInstant(date, deliveryTime);
  }
  return instant;
}
