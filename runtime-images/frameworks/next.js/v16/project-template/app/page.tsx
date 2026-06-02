export default function Home() {
  return (
    <main className="page">
      <section className="shell" aria-labelledby="page-title">
        <div className="intro">
          <p className="eyebrow">DevBox runtime</p>
          <h1 id="page-title">Next.js is ready.</h1>
          <p className="summary">
            Build routes in the App Router, iterate with hot reload, and switch
            to the production server when your app is ready to ship.
          </p>
          <div className="actions" aria-label="Project links">
            <a className="button" href="https://nextjs.org/docs">
              Next.js Docs
            </a>
            <a className="button secondary" href="https://sealos.io/">
              Sealos
            </a>
          </div>
        </div>

        <div className="details" aria-label="Runtime details">
          <article className="detail">
            <h2>App Router</h2>
            <p>Create pages, layouts, and loading states under the app folder.</p>
          </article>
          <article className="detail">
            <h2>TypeScript</h2>
            <p>Template files are typed by default for confident iteration.</p>
          </article>
          <article className="detail">
            <h2>Port 3000</h2>
            <p>The entrypoint binds to all interfaces for DevBox access.</p>
          </article>
        </div>
      </section>
    </main>
  );
}
