class Products {
  int id;
  String key;
  String name;
  int price;
  int salePrice;
  int discount;
  dynamic pictures;
  String shortDetails;
  String description;
  int stock;
  bool is_new;
  bool sale;
  String category;
  dynamic colors;
  dynamic size;
  dynamic tags;
  dynamic variants;

  dynamic items;
  String scheduled_sales_period;
  int weight;
  String created_date;
  String modified_date;
  String created_by;
  String dynamic_link;
  String menu_link;
  bool deleted;
  int ratingTotal;
  double ratingValue;

  Products(
      {this.id,
      this.key,
      this.name,
      this.price,
      this.salePrice,
      this.discount,
      this.pictures,
      this.shortDetails,
      this.description,
      this.stock,
      this.is_new,
      this.sale,
      this.category,
      this.colors,
      this.size,
      this.tags,
      this.variants,
      this.items,
      this.scheduled_sales_period,
      this.weight,
      this.created_date,
      this.modified_date,
      this.created_by,
      this.dynamic_link,
      this.menu_link,
      this.deleted,
      this.ratingTotal,
      this.ratingValue});

  Map<String, dynamic> toJSON() {
    return new Map.from({
      'id': id,
      'key': key,
      'name': name,
      'price': price,
      'salePrice': salePrice,
      'discount': discount,
      'pictures': pictures,
      'shortDetails': shortDetails,
      'description': description,
      'stock': stock,
      'is_new': is_new,
      'sale': sale,
      'category': category,
      'colors': colors,
      'size': size,
      'tags': tags,
      'variants': variants,
      'items': items,
      'scheduled_sales_period': scheduled_sales_period,
      'weight': weight,
      'created_date': created_date,
      'modified_date': modified_date,
      'created_by': created_by,
      'dynamic_link': dynamic_link,
      'menu_link': menu_link,
      'deleted': deleted,
      'ratingTotal': ratingTotal,
      'ratingValue': ratingValue
    });
  }

  Products.fromJson(dynamic snapshot) {
    id = snapshot['id'];
    key = snapshot['key'];
    name = snapshot['name'];
    price = snapshot['price'];
    salePrice = snapshot['salePrice'];
    discount = snapshot['discount'];
    pictures = snapshot['pictures'];
    shortDetails = snapshot['shortDetails'];
    description = snapshot['description'];
    stock = snapshot['stock'];
    is_new = snapshot['is_new'];
    sale = snapshot['sale'];
    category = snapshot['category'];
    colors = snapshot['colors'];
    size = snapshot['size'];
    tags = snapshot['tags'];
    variants = snapshot['variants'];
    items = snapshot['items'];
    scheduled_sales_period = snapshot['scheduled_sales_period'];
    weight = snapshot['weight'];
    created_date = snapshot['created_date'];
    modified_date = snapshot['modified_date'];
    created_by = snapshot['created_by'];
    dynamic_link = snapshot['dynamic_link'];
    menu_link = snapshot['menu_link'];
    deleted = snapshot['deleted'];
    ratingTotal = snapshot['ratingTotal'];
    ratingValue = snapshot['ratingValue'];
  }
}

class Item {
  final String display;
  final String value;
  final String id;

  Item({this.display, this.value, this.id});
}
