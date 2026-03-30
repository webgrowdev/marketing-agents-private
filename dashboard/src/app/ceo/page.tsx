import { apiGet } from "../../components/api";

type Campaign = { id: string; name: string; status: string; priority: number };
type Metrics = { successRate: number; blockedTasks: number; throughput: number; failedRate: number };

export default async function CeoPage() {
  const [campaigns, metrics] = await Promise.all([
    apiGet<Campaign[]>("/campaigns"),
    apiGet<Metrics>("/metrics/overview")
  ]);

  return (
    <main className="space-y-4">
      <div className="grid grid-cols-2 gap-4">
        <div className="card"><h2 className="font-semibold">Campañas activas</h2><p>{campaigns.filter(c => c.status === "active").length}</p></div>
        <div className="card"><h2 className="font-semibold">Progreso global</h2><p>{Math.round(metrics.successRate * 100)}%</p></div>
        <div className="card"><h2 className="font-semibold">Riesgos / bloqueos</h2><p>{metrics.blockedTasks}</p></div>
        <div className="card"><h2 className="font-semibold">Failed rate</h2><p>{Math.round(metrics.failedRate * 100)}%</p></div>
      </div>
      <div className="card">
        <h2 className="mb-2 font-semibold">Resumen diario/semanal</h2>
        <p>Throughput 24h: {metrics.throughput} tareas completadas.</p>
      </div>
    </main>
  );
}
