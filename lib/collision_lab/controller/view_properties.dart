/// View-only flags — `js/common/view/CollisionLabViewProperties.js`
class ViewProperties {
  bool velocityVectorVisible = true;
  bool momentumVectorVisible = false;
  bool valuesVisible = false;
  bool kineticEnergyVisible = false;
  bool moreDataVisible = false;

  void reset() {
    velocityVectorVisible = true;
    momentumVectorVisible = false;
    valuesVisible = false;
    kineticEnergyVisible = false;
    moreDataVisible = false;
  }
}
