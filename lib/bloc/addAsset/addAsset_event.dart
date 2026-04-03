import '../../services/portfolio_services.dart';

abstract class AddAssetEvent {}

class LoadAssetData extends AddAssetEvent {}

class UpdateQuantity extends AddAssetEvent {
  final double quantity;

  UpdateQuantity({required this.quantity});
}

class UpdatePurchasePrice extends AddAssetEvent {
  final double price;

  UpdatePurchasePrice({required this.price});
}

class UpdateNotes extends AddAssetEvent {
  final String notes;

  UpdateNotes({required this.notes});
}

class UpdateAssetName extends AddAssetEvent {
  final String assetName;

  UpdateAssetName({required this.assetName});
}

class SelectPortfolio extends AddAssetEvent {
  final Portfolio portfolio;

  SelectPortfolio({required this.portfolio});
}

class SaveAsset extends AddAssetEvent {}