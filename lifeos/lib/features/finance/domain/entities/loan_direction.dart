/// Which way a loan runs: money you lent out ([given], an asset — someone
/// owes you) or money you borrowed ([borrowed], a liability — you owe
/// someone).
enum LoanDirection {
  given('Money I lent'),
  borrowed('Money I borrowed');

  const LoanDirection(this.label);

  final String label;
}
