enum ProductStatus {
  draft,
  submitted,
  automatedReview,
  manualReview,
  informationRequired,
  pendingApproval,
  active,
  inactive,
  outOfStock,
  rejected,
  restricted,
  suspended,
  recalled,
  archived,
  deleted;

  static ProductStatus fromStorage(String? value) {
    switch ((value ?? '').trim()) {
      case 'draft':
        return ProductStatus.draft;
      case 'submitted':
        return ProductStatus.submitted;
      case 'automatedReview':
        return ProductStatus.automatedReview;
      case 'manualReview':
        return ProductStatus.manualReview;
      case 'informationRequired':
        return ProductStatus.informationRequired;
      case 'pendingApproval':
      case 'pending_approval':
        return ProductStatus.pendingApproval;
      case 'active':
      case 'approved':
        return ProductStatus.active;
      case 'inactive':
        return ProductStatus.inactive;
      case 'outOfStock':
      case 'out_of_stock':
        return ProductStatus.outOfStock;
      case 'rejected':
        return ProductStatus.rejected;
      case 'restricted':
        return ProductStatus.restricted;
      case 'suspended':
        return ProductStatus.suspended;
      case 'recalled':
        return ProductStatus.recalled;
      case 'archived':
        return ProductStatus.archived;
      case 'deleted':
        return ProductStatus.deleted;
      default:
        return ProductStatus.draft;
    }
  }
}

extension ProductStatusX on ProductStatus {
  String get id {
    return switch (this) {
      ProductStatus.draft => 'draft',
      ProductStatus.submitted => 'submitted',
      ProductStatus.automatedReview => 'automatedReview',
      ProductStatus.manualReview => 'manualReview',
      ProductStatus.informationRequired => 'informationRequired',
      ProductStatus.pendingApproval => 'pendingApproval',
      ProductStatus.active => 'active',
      ProductStatus.inactive => 'inactive',
      ProductStatus.outOfStock => 'outOfStock',
      ProductStatus.rejected => 'rejected',
      ProductStatus.restricted => 'restricted',
      ProductStatus.suspended => 'suspended',
      ProductStatus.recalled => 'recalled',
      ProductStatus.archived => 'archived',
      ProductStatus.deleted => 'deleted',
    };
  }

  bool get isVisibleInCatalog => this == ProductStatus.active;
}
