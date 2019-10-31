class Category {
  final String id;
  final String main_category_id;
  final String name;
  final String description;
  final String created_date;
  final String created_by;
  final String image;
  final bool deleted;
  final String meta;
  final String modified_date;
  final String link;
  final String merchant;

  Category(
      {this.id,
      this.main_category_id,
      this.name,
      this.description,
      this.created_date,
      this.created_by,
      this.image,
      this.deleted,
      this.meta,
      this.modified_date,
      this.link,
      this.merchant});
}
