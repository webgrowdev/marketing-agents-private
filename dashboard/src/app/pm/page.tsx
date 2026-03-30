import { apiGet } from "../../components/api";

type Task = { id: string; title: string; status: string; priority: number; retries: number; dependsOnTaskId?: string | null; agent: { slug: string } };

export default async function PmPage() {
  const tasks = await apiGet<Task[]>("/tasks");

  return (
    <main className="card">
      <h2 className="mb-3 font-semibold">Backlog PM</h2>
      <table className="w-full text-sm">
        <thead><tr className="text-left"><th>Tarea</th><th>Agente</th><th>Estado</th><th>Prio</th><th>Reintentos</th><th>Dependencia</th></tr></thead>
        <tbody>
          {tasks.slice(0, 100).map((t) => (
            <tr key={t.id} className="border-t border-slate-800">
              <td className="py-2">{t.title}</td><td>{t.agent.slug}</td><td>{t.status}</td><td>{t.priority}</td><td>{t.retries}</td><td>{t.dependsOnTaskId ?? "-"}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </main>
  );
}
