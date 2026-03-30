import { apiGet } from "../../components/api";

type Event = { id: string; type: string; severity: string; message: string; createdAt: string };

export default async function ActivityPage() {
  const events = await apiGet<Event[]>("/events");
  return (
    <main className="card">
      <h2 className="mb-3 font-semibold">Timeline en vivo</h2>
      <ul className="space-y-2 text-sm">
        {events.map((e) => (
          <li key={e.id} className="border-b border-slate-800 pb-2">
            <strong>[{e.severity}]</strong> {e.type} — {e.message}
          </li>
        ))}
      </ul>
    </main>
  );
}
