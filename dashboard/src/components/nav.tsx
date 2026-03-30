import Link from "next/link";

const links = [
  ["CEO", "/ceo"],
  ["PM", "/pm"],
  ["Activity", "/activity"],
  ["Metrics", "/metrics"]
] as const;

export function Nav() {
  return (
    <nav className="mb-6 flex gap-3 text-sm">
      {links.map(([label, href]) => (
        <Link key={href} href={href} className="rounded bg-slate-800 px-3 py-2 hover:bg-slate-700">
          {label}
        </Link>
      ))}
    </nav>
  );
}
