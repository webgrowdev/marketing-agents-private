import { apiGet } from "../../components/api";

type Metrics = {
  throughput: number;
  successRate: number;
  failedRate: number;
  averageCompletionTimeMs: number;
  blockedTasks: number;
  tasksCompletedPerAgent: Array<{ agentId: string; _count: { id: number } }>;
};

export default async function MetricsPage() {
  const m = await apiGet<Metrics>("/metrics/overview");
  return (
    <main className="space-y-4">
      <div className="grid grid-cols-3 gap-4">
        <div className="card">Throughput: {m.throughput}</div>
        <div className="card">Success rate: {Math.round(m.successRate * 100)}%</div>
        <div className="card">Failed rate: {Math.round(m.failedRate * 100)}%</div>
        <div className="card">Avg completion: {Math.round(m.averageCompletionTimeMs)} ms</div>
        <div className="card">Blocked tasks: {m.blockedTasks}</div>
      </div>
      <div className="card">
        <h2 className="mb-2 font-semibold">Tasks completed per agent</h2>
        <ul>{m.tasksCompletedPerAgent.map((a) => <li key={a.agentId}>{a.agentId}: {a._count.id}</li>)}</ul>
      </div>
    </main>
  );
}
