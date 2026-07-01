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
      case 'automated_review':
        return ProductStatus.automatedReview;
      case 'manualReview':
      case 'manual_review':
        return ProductStatus.manualReview;
      case 'informationRequired':
      case 'information_required':
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
      ProductStatus.automatedReview => 'automated_review',
      ProductStatus.manualReview => 'manual_review',
      ProductStatus.informationRequired => 'information_required',
      ProductStatus.pendingApproval => 'pending_approval',
      ProductStatus.active => 'active',
      ProductStatus.inactive => 'inactive',
      ProductStatus.outOfStock => 'out_of_stock',
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
