import 'package:campus_dual_android/scripts/campus_dual_manager.models.dart';
import 'package:campus_dual_android/scripts/campus_dual_manager.dart';
import 'package:test/test.dart';

void main() {
  test('CampusDualManager', () {
    CampusDualManager.userCreds = UserCredentials(
      "test",
      "test",
      "hash",
      false,
    );
    expect(CampusDualManager.userCreds!.username, 'test');
    expect(CampusDualManager.userCreds!.password, 'test');
  });
}
