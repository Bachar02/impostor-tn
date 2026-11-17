/// PROPOSED CATEGORY LABELS (D-37). [REVIEW]: not approved by a Tunisian
/// Derja reviewer. They are display labels only, not word content: no pack,
/// word or ID exists for them (Q-13). Kept in sync by hand with
/// `docs/ARABIC_LOCALIZATION.md` §5.1.
library;

/// The eight initial labels, in the Product Owner's order.
const proposedInitialLabels = <String>[
  'مكلة',
  'بلايص',
  'حيوانات',
  'خدمة',
  'حاجات في الدار',
  'تنقّل',
  'رياضة',
  'فنّ وفرجة',
];

/// Candidates for later content.
const proposedLaterLabels = <String>[
  'تكنولوجيا',
  'بدن الإنسان',
  'قراية',
  'حاجات في الشارع',
  'عادات وتقاليد',
];

const proposedLabels = [...proposedInitialLabels, ...proposedLaterLabels];
