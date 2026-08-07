/// Whether a category groups money coming in or going out. A category
/// only ever belongs to one, so the picker in the transaction form can
/// filter to just the categories relevant to the transaction type being
/// entered.
enum CategoryType {
  income('Income'),
  expense('Expense');

  const CategoryType(this.label);

  final String label;
}
