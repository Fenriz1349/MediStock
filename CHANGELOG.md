# Changelog

## [1.14.0](https://github.com/Fenriz1349/MediStock/compare/v1.13.0...v1.14.0) (2026-08-10)


### Features

* add isLoading in every VM / Views handling async ([d7b248a](https://github.com/Fenriz1349/MediStock/commit/d7b248a4ac80429bef3bf8e073a27abb1b266b73))
* add NetworkMonitor and NetworkMonitoring ([63009ee](https://github.com/Fenriz1349/MediStock/commit/63009ee42b7bc89206cc22db3e8590e03b7f4336))
* add OfflineView, rework ContentView and offlinemode ([eeae362](https://github.com/Fenriz1349/MediStock/commit/eeae362e0c43bd99ce1640a06e809fc79b8f2086))
* rework verifyReachable to throw error, implement networkMonitor ([19eccb7](https://github.com/Fenriz1349/MediStock/commit/19eccb7799976d03f79bd712f43c56e7dfa5b0b4))

## [1.13.0](https://github.com/Fenriz1349/MediStock/compare/v1.12.0...v1.13.0) (2026-08-10)


### Features

* add ascendent / descendent sorting in AisleListView ([8f5d708](https://github.com/Fenriz1349/MediStock/commit/8f5d708b171b71a1bfc4dd90d65dd086f4d565ae))
* add MedicineNameFormat and MedicineNameFormatTest ([9462ca7](https://github.com/Fenriz1349/MediStock/commit/9462ca77c4cc57da24f1181a674ebcbdbd0bc77b))
* add observeMedicines, AllMedicinesView use it for text search ([6372185](https://github.com/Fenriz1349/MediStock/commit/63721858b64e9ec85c821f023b553bbdd3e857d1))
* add search bar in AisleListView ([ae49a1e](https://github.com/Fenriz1349/MediStock/commit/ae49a1e474bd1890c50df50626cfb9ddcd9dbd94))
* addMedicine use new rule ([bd81755](https://github.com/Fenriz1349/MediStock/commit/bd81755afc16f811e71ffefd1bc23dd22ea837f8))
* update observeMedicines to add ascending, add ascending / descending button in AllMedicineView ([de1b2b4](https://github.com/Fenriz1349/MediStock/commit/de1b2b4a6eeafe5c2a477a3d1162a93121c4ca2c))

## [1.12.0](https://github.com/Fenriz1349/MediStock/compare/v1.11.0...v1.12.0) (2026-08-10)


### Features

* add AisleListViewModel ([5e942f6](https://github.com/Fenriz1349/MediStock/commit/5e942f6267d4c216be38297b00ec80c3dd8a0156))
* add AisleMedicinesViewModel to handle specifically AisleMedicinesView ([578c2db](https://github.com/Fenriz1349/MediStock/commit/578c2db0f899fdfa0f159b1292977045732687e9))
* add AllMedicinesViewModel ([bca6e97](https://github.com/Fenriz1349/MediStock/commit/bca6e9762b5b4063dffaa148df6710860ab345b9))
* add public listner functions and refactor observe in a private concrete listener creator ([57bf18a](https://github.com/Fenriz1349/MediStock/commit/57bf18ac3fc4fac9034a8872961e40f7f751a0f8))

## [1.11.0](https://github.com/Fenriz1349/MediStock/compare/v1.10.0...v1.11.0) (2026-08-07)


### Features

* add currentUser in FirebaseAuthenticationService, implement actual FirestoreHistoryStore functions, remove authenticationVM from all view ([1d3af89](https://github.com/Fenriz1349/MediStock/commit/1d3af89125ee3ec3b7249d8cf217786b0249d452))
* add timestamp ordering ([40a4d6a](https://github.com/Fenriz1349/MediStock/commit/40a4d6aa2e9780b5b7720ce0c8d3145183331228))
* update recordAddition and recordDeletion details label ([2dab844](https://github.com/Fenriz1349/MediStock/commit/2dab8444fd93ef6cb38532f773a4763401626375))

## [1.10.0](https://github.com/Fenriz1349/MediStock/compare/v1.9.0...v1.10.0) (2026-08-07)


### Features

* add mapError in FirestoreMedicineStore and FirestoreHistoryStore ([ebfc974](https://github.com/Fenriz1349/MediStock/commit/ebfc9745fb73562f15075aff58287b5e5af9e03e))
* add MedicineError and MedicineErrorMessage ([09c16b8](https://github.com/Fenriz1349/MediStock/commit/09c16b8e5ef57ec28fed24753f64569a19771df6))
* add Toasty display in MedicineDetailView, AllMedicinesView, AisleListView and ContentView ([0f5e485](https://github.com/Fenriz1349/MediStock/commit/0f5e48519b94c1322411dadb4122a9779896a482))
* rework VM with error handlign and no try? ([2860fd4](https://github.com/Fenriz1349/MediStock/commit/2860fd496f139a855dea8a597918e7d2d77bd6ce))


### Bug Fixes

* fix catalogViewModel.listen() in ContentView ([d1b3d72](https://github.com/Fenriz1349/MediStock/commit/d1b3d729d75988c162d16b7ce3b489e46679e557))

## [1.9.0](https://github.com/Fenriz1349/MediStock/compare/v1.8.0...v1.9.0) (2026-08-07)


### Features

* add AuthenticationError and AuthenticationErrorMessage for localisation, add mapError in FirebaseAuthenticationService ([1ea58ad](https://github.com/Fenriz1349/MediStock/commit/1ea58ad82508e09dc46c418ccd12d1ce809db982))
* add PasswordPolicy to handle password validation rules, PasswordRequirement to handle localisation ([1f2bac5](https://github.com/Fenriz1349/MediStock/commit/1f2bac5c7fb00fbf62919c0a61b1588aa9a6c62a))
* add Toasty in UserView and AuthenticationView to display errorMessage ([4635353](https://github.com/Fenriz1349/MediStock/commit/463535321f166b74e40d884ce3352baf466b77fa))
* add ToastyContainer over ContentView ([a729335](https://github.com/Fenriz1349/MediStock/commit/a7293357ee73adaff1c3cef544cbc8e062ed6412))
* rework AuthenticationViewModel to catch error un AuthenticationError instead of print ([627b07a](https://github.com/Fenriz1349/MediStock/commit/627b07a7c8605ba2a9049f45c514913c5ace3fe9))

## [1.8.0](https://github.com/Fenriz1349/MediStock/compare/v1.7.0...v1.8.0) (2026-08-07)


### Features

* add UserView with logout and delete account, add it in tabview ([a9c7c18](https://github.com/Fenriz1349/MediStock/commit/a9c7c18e6e85f10e7c3473b75082f50f73aa99b1))


### Bug Fixes

* fix alert in UserView ([f0bcdcc](https://github.com/Fenriz1349/MediStock/commit/f0bcdcc86ad332d68e1a964def0de5833c6eaea4))

## [1.7.0](https://github.com/Fenriz1349/MediStock/compare/v1.6.0...v1.7.0) (2026-08-07)


### Features

* add AisleLabel to handal localisation and label name, fix navigation ([dff3537](https://github.com/Fenriz1349/MediStock/commit/dff35373499ba90aa7a452667c6f67615d7cf2ea))

## [1.6.0](https://github.com/Fenriz1349/MediStock/compare/v1.5.0...v1.6.0) (2026-08-07)


### Features

* in AddMedicineView add cancel button, stock textfield starts now with empty fields ([441befa](https://github.com/Fenriz1349/MediStock/commit/441befad7e046bc77149e355204003262860a647))


### Bug Fixes

* in MedicineDetailView change  TextField for Text to actually display stock ([31f094d](https://github.com/Fenriz1349/MediStock/commit/31f094ddaf6b77fe3b8fbd4c285e52f3ab926dc2))
* stock buttons closing detail page ([c450b6e](https://github.com/Fenriz1349/MediStock/commit/c450b6e8e64d0dc5a9d0fc9459cb4911fb9ba1c4))

## [1.5.0](https://github.com/Fenriz1349/MediStock/compare/v1.4.1...v1.5.0) (2026-08-06)


### Features

* add delete on medecine ([0bac8c2](https://github.com/Fenriz1349/MediStock/commit/0bac8c2846e3ffd797911a0e40fe702dbdb58e49))
* add delete on medecine ([406a724](https://github.com/Fenriz1349/MediStock/commit/406a724247b7caccdb6a7ee2c7529ffea4500590))

## [1.4.1](https://github.com/Fenriz1349/MediStock/compare/v1.4.0...v1.4.1) (2026-08-06)


### Bug Fixes

* add ci-skip.yml to prevent CI for bump version bot ([e99c69c](https://github.com/Fenriz1349/MediStock/commit/e99c69c4bec7d118a143cfdad098eb738c8534a4))
* fix package destination ([93c1680](https://github.com/Fenriz1349/MediStock/commit/93c1680402cfb9cf5cae83bee1191d029e78d930))

## [1.4.0](https://github.com/Fenriz1349/MediStock/compare/v1.3.1...v1.4.0) (2026-08-06)


### Features

* add AddMedicineView, change addRandomMedicine into functionnal addMedicine ([831a6e7](https://github.com/Fenriz1349/MediStock/commit/831a6e7f9f57392fc3b93977c5f7c417dbd82adb))
* add AisleCodeTest, remove cleanedAisle ([c84e37f](https://github.com/Fenriz1349/MediStock/commit/c84e37f2709aec879bced2d2bdd0f7fb48a4ffe2))
* add MedicineFormContent ([6cfc181](https://github.com/Fenriz1349/MediStock/commit/6cfc181d12b31605a11b9d483a76d9bb426da766))


### Bug Fixes

* add concurrency for flow ([77f3ef2](https://github.com/Fenriz1349/MediStock/commit/77f3ef2639b9596f5b054ee507261b938fa843e3))
* fix tests ([48b8614](https://github.com/Fenriz1349/MediStock/commit/48b8614b80c19094a34ceacd0fa8c626f779d8cd))
