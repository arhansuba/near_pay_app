import 'package:get_it/get_it.dart';
import 'package:near_pay_app/data/network/api_service.dart';
<<<<<<< HEAD

=======
>>>>>>> dfa4b98bee355a1c88fba68c63fd3df725aef5d0


final GetIt getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerSingleton<ApiService>(ApiService());
  //Add more dependicies like near blockchain service crypto service js engines integration payment etc..
}
