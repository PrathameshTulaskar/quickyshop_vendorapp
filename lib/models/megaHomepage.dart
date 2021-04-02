class VendorMegaData{
  String vendorId;
  String vendorName;
  int totalOrders;
  int totalSales;
  int totalDeliveries;
  VendorMegaData(this.vendorName, this.totalDeliveries,this.totalOrders,this.totalSales,this.vendorId);
  VendorMegaData.fromJson(Map<String, dynamic> json):
  vendorName = json['userName'],
  totalOrders = json['totalOrders'],
  totalSales = json['totalSales'],
  totalDeliveries = json['totalDeliveries'];
}