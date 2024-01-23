class Products {
  String img;
  String productName;
  int price;
  int qty;
  int stock;

  Products(
      {required this.img,
      required this.productName,
      required this.price,
      this.qty = 0,
      this.stock = 10});
}
