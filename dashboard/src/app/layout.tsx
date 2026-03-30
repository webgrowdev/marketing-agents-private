import "./globals.css";
import { Nav } from "../components/nav";

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="mx-auto max-w-6xl p-6">
        <h1 className="mb-2 text-2xl font-bold">Marketing Multi-Agent Control Tower</h1>
        <Nav />
        {children}
      </body>
    </html>
  );
}
