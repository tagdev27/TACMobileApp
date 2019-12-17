class Reviews {
  final String id;
  final String name;
  final String email;
  final String title;
  final String text;
  final int rating;
  final String created_date;
  final String product_key;

  Reviews(
      {this.id,
      this.name,
      this.email,
      this.title,
      this.text,
      this.rating,
      this.created_date,
      this.product_key});
}
