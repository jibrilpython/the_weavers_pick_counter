enum InstrumentType {
  foldingPickCounter('Folding Pick Counter'),
  yarnTwistTester('Yarn Twist Tester'),
  threadReel('Thread Reel'),
  clothBalance('Cloth Balance'),
  moistureMeter('Moisture Meter'),
  fiberMicrometer('Fiber Micrometer'),
  other('Other');

  const InstrumentType(this.label);
  final String label;
}

enum OperationType {
  manualFolding('Manual Folding'),
  handCranked('Hand-Cranked'),
  gravityWeight('Gravity-Based Weight'),
  other('Other');

  const OperationType(this.label);
  final String label;
}

enum ConditionState {
  pristine('Pristine — Museum Quality'),
  restored('Restored — Mechanism Mobile'),
  minorWear('Minor Wear — Original Finish'),
  corroded('Corroded — Active Deterioration'),
  immobile('Immobile — Seized Mechanism'),
  unknown('Unknown');

  const ConditionState(this.label);
  final String label;
}

enum CountryOfOrigin {
  ukLancashire('UK — Lancashire'),
  ukYorkshire('UK — Yorkshire'),
  usa('USA'),
  switzerland('Switzerland'),
  germany('Germany'),
  india('India'),
  other('Other');

  const CountryOfOrigin(this.label);
  final String label;
}

enum Era {
  era1880s('1880s'),
  era1910s('1910s'),
  era1930s('1930s'),
  era1950s('1950s'),
  era1960s('1960s'),
  other('Uncertain');

  const Era(this.label);
  final String label;
}

enum InstrumentMaterial {
  polishedBrass('Polished Brass'),
  castIron('Cast Iron'),
  vulcanite('Vulcanite'),
  glassOptics('Glass Optics'),
  nickelPlating('Nickel Plating'),
  other('Other');

  const InstrumentMaterial(this.label);
  final String label;
}
