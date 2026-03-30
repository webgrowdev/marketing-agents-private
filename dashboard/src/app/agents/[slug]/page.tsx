import { apiGet } from "../../../components/api";

type Agent = { slug: string; runs: Array<{ id: string; status: string; durationMs: number | null }>; tasks: Array<{ id: string; title: string; status: string }>; logs: Array<{ id: string; message: string }> };

export default async function AgentPage({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  const agent = await apiGet<Agent>(`/agents/${slug}`);
  const totalRuns = agent.runs.length;
  const success = agent.runs.filter((r) => r.status === "completed").length;
  const avg = agent.runs.reduce((acc, r) => acc + (r.durationMs ?? 0), 0) / Math.max(totalRuns, 1);

  return (
    <main className="space-y-4">
      <div className="grid grid-cols-3 gap-4">
        <div className="card">Runs totales: {totalRuns}</div>
        <div className="card">Tiempo medio: {Math.round(avg)} ms</div>
        <div className="card">Tasa éxito: {Math.round((success / Math.max(totalRuns, 1)) * 100)}%</div>
      </div>
      <div className="card"><h3 className="font-semibold">Tareas actuales</h3><ul>{agent.tasks.map((t) => <li key={t.id}>{t.title} — {t.status}</li>)}</ul></div>
      <div className="card"><h3 className="font-semibold">Errores/Salidas recientes</h3><ul>{agent.logs.map((l) => <li key={l.id}>{l.message}</li>)}</ul></div>
    </main>
  );
}
