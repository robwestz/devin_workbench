export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-24">
      <h1 className="text-4xl font-bold">{{PROJECT_NAME}}</h1>
      <p className="mt-4 text-muted-foreground">
        Bootstrapped from devin-workbench.
      </p>
    </main>
  );
}
