class product_model {
  final String pimg;
  final String title;
  final String sku;
  final String stock;
  final String quant;
  final String status;
  final String cdate;

  product_model(this.pimg, this.title, this.sku, this.stock, this.quant,
      this.status, this.cdate);
}

List<product_model> productData = [
  new product_model('images/p1.png', 'California Walnuts', '3859539',
      'In Stock', '89', 'Active', '02/01/2022 09:16:00'),
  new product_model('images/p3.png', 'Iranian Pistachios', '3859538',
      'In Stock', '46', 'Active', '05/02/2022 09:16:00'),
  new product_model('images/p2.png', 'Iranian Pistachios', '3859537',
      'In Stock', '36', 'Active', '03/01/2022 10:16:00'),
];
