# Changelog

## [2.1.0](https://github.com/Fenriz1349/MediStock/compare/v2.0.0...v2.1.0) (2026-08-17)


### Features

* add AccentListRow ([02f776a](https://github.com/Fenriz1349/MediStock/commit/02f776a2d21c5a3521a2d4c1fe6249e49eba24a8))
* add AccessibilityHandler, implement accessibilityLabel in all views ([94a1573](https://github.com/Fenriz1349/MediStock/commit/94a157300655e8dd15170879e02f6bfc74282d34))
* add AddMedicineView, change addRandomMedicine into functionnal addMedicine ([831a6e7](https://github.com/Fenriz1349/MediStock/commit/831a6e7f9f57392fc3b93977c5f7c417dbd82adb))
* add AddMedicineViewModel, Implement CustomTextFields in MedicineFormContent and AddMedicineView ([022e616](https://github.com/Fenriz1349/MediStock/commit/022e61675c2c249efd2b1bdae19406076780e682))
* add AisleCodeTest, remove cleanedAisle ([c84e37f](https://github.com/Fenriz1349/MediStock/commit/c84e37f2709aec879bced2d2bdd0f7fb48a4ffe2))
* add AisleLabel to handal localisation and label name, fix navigation ([dff3537](https://github.com/Fenriz1349/MediStock/commit/dff35373499ba90aa7a452667c6f67615d7cf2ea))
* add AisleListViewModel ([5e942f6](https://github.com/Fenriz1349/MediStock/commit/5e942f6267d4c216be38297b00ec80c3dd8a0156))
* add AisleMedicinesViewModel to handle specifically AisleMedicinesView ([578c2db](https://github.com/Fenriz1349/MediStock/commit/578c2db0f899fdfa0f159b1292977045732687e9))
* add AllMedicinesViewModel ([bca6e97](https://github.com/Fenriz1349/MediStock/commit/bca6e9762b5b4063dffaa148df6710860ab345b9))
* add AppButtonStyle ([ad6f6eb](https://github.com/Fenriz1349/MediStock/commit/ad6f6eb1257dd2e312b04d7810f7dac101866b97))
* add AppIcon, AccentColor ([49e9e32](https://github.com/Fenriz1349/MediStock/commit/49e9e3251343a66eb7aababf7a286a13813ad85d))
* add AppLogo and implement it in AuthenticationView, OfflineView ([91b3214](https://github.com/Fenriz1349/MediStock/commit/91b321437efb948512774641d8a3185455b229b3))
* add ascendent / descendent sorting in AisleListView ([8f5d708](https://github.com/Fenriz1349/MediStock/commit/8f5d708b171b71a1bfc4dd90d65dd086f4d565ae))
* add AuthenticationError and AuthenticationErrorMessage for localisation, add mapError in FirebaseAuthenticationService ([1ea58ad](https://github.com/Fenriz1349/MediStock/commit/1ea58ad82508e09dc46c418ccd12d1ce809db982))
* add CircleIconButtonStyle, use it for all circular buttons ([16c8977](https://github.com/Fenriz1349/MediStock/commit/16c89778d50f08dd8b1f1113f88e78d0a091ceeb))
* add currentUser in FirebaseAuthenticationService, implement actual FirestoreHistoryStore functions, remove authenticationVM from all view ([1d3af89](https://github.com/Fenriz1349/MediStock/commit/1d3af89125ee3ec3b7249d8cf217786b0249d452))
* add delete in MedicineStoring and recordDeletion in HistoryStoring ([8eea52f](https://github.com/Fenriz1349/MediStock/commit/8eea52fac2da32651a7c326bd5b105c788ae85d2))
* add delete on medecine ([0bac8c2](https://github.com/Fenriz1349/MediStock/commit/0bac8c2846e3ffd797911a0e40fe702dbdb58e49))
* add delete on medecine ([406a724](https://github.com/Fenriz1349/MediStock/commit/406a724247b7caccdb6a7ee2c7529ffea4500590))
* add dispatchQueue in FirebaseApp.configure() to handle it outside mainthread ([aa6f1bf](https://github.com/Fenriz1349/MediStock/commit/aa6f1bf1a597ea1d875a70dcee1af635e837cab6))
* add EmailPolicy and CustomTextfield package ([541462a](https://github.com/Fenriz1349/MediStock/commit/541462a7d4f8ddfd79ba15eee47c1b685e0910ac))
* add FirestoreAisleStore, AisleSummary, AisleStoring and AisleStoringDouble ([0bb9a75](https://github.com/Fenriz1349/MediStock/commit/0bb9a7569192c2f342f9e69d13b2c2d726a339bb))
* add focusState on name for MedicineContent, and on email for AuthenticationView only in VO ([3b15415](https://github.com/Fenriz1349/MediStock/commit/3b154156c0c90553a05bcd5c1524da573af59654))
* add HistoryEntryLocalized and implement it in MedicineDetailHistorySection, rework MedicineDetailHistorySection ([d2b9aee](https://github.com/Fenriz1349/MediStock/commit/d2b9aee3e8e826621a2c1226263907573fb4a3c9))
* add index filter for AisleMedicinesViewModel ([31f0697](https://github.com/Fenriz1349/MediStock/commit/31f06976dfd127112941db6745cb0d6702bd60f4))
* add isLoading in every VM / Views handling async ([d7b248a](https://github.com/Fenriz1349/MediStock/commit/d7b248a4ac80429bef3bf8e073a27abb1b266b73))
* add KeyboardToolBar to display close and validate buttons on every keyboard ([31b0db3](https://github.com/Fenriz1349/MediStock/commit/31b0db3d67d40434b321402b4f50cb52e026f203))
* add LoadingView and implement it ([aa726d0](https://github.com/Fenriz1349/MediStock/commit/aa726d0b78eaa78e49c85f1deb6916c41525758b))
* add mapError in FirestoreMedicineStore and FirestoreHistoryStore ([ebfc974](https://github.com/Fenriz1349/MediStock/commit/ebfc9745fb73562f15075aff58287b5e5af9e03e))
* add MedicineError and MedicineErrorMessage ([09c16b8](https://github.com/Fenriz1349/MediStock/commit/09c16b8e5ef57ec28fed24753f64569a19771df6))
* add MedicineFormContent ([6cfc181](https://github.com/Fenriz1349/MediStock/commit/6cfc181d12b31605a11b9d483a76d9bb426da766))
* add MedicineNameFormat and MedicineNameFormatTest ([9462ca7](https://github.com/Fenriz1349/MediStock/commit/9462ca77c4cc57da24f1181a674ebcbdbd0bc77b))
* add MedicinePolicy and MedicinePolicyTests ([5aead23](https://github.com/Fenriz1349/MediStock/commit/5aead23ce87ecccffb4aa49ceaa3249e57ee18ec))
* add NetworkMonitor and NetworkMonitoring ([63009ee](https://github.com/Fenriz1349/MediStock/commit/63009ee42b7bc89206cc22db3e8590e03b7f4336))
* add observeMedicines, AllMedicinesView use it for text search ([6372185](https://github.com/Fenriz1349/MediStock/commit/63721858b64e9ec85c821f023b553bbdd3e857d1))
* add OfflineView, rework ContentView and offlinemode ([eeae362](https://github.com/Fenriz1349/MediStock/commit/eeae362e0c43bd99ce1640a06e809fc79b8f2086))
* add PaginationPolicy and lazy / pagination in every Views, update tests ([bd0c409](https://github.com/Fenriz1349/MediStock/commit/bd0c40945d0a8fc6ef3a09e33b2479f76ca98a22))
* add password reset button in authentication view ([78166f8](https://github.com/Fenriz1349/MediStock/commit/78166f88499ebb2c56bfe9fa4e8b81aa7963ff23))
* add PasswordPolicy to handle password validation rules, PasswordRequirement to handle localisation ([1f2bac5](https://github.com/Fenriz1349/MediStock/commit/1f2bac5c7fb00fbf62919c0a61b1588aa9a6c62a))
* add picker with aislesSummary in MedicineFormContent, add test ([f0e3291](https://github.com/Fenriz1349/MediStock/commit/f0e3291e402c850ca78bf0224457d3d09d3e329e))
* add PreviewHelper ([229d14e](https://github.com/Fenriz1349/MediStock/commit/229d14ec3effed6c792076372f7156677414b5bf))
* add public listner functions and refactor observe in a private concrete listener creator ([57bf18a](https://github.com/Fenriz1349/MediStock/commit/57bf18ac3fc4fac9034a8872961e40f7f751a0f8))
* add sanitizedStock ([7e4a8da](https://github.com/Fenriz1349/MediStock/commit/7e4a8da31e7c39273198131d213559188dde186a))
* add search bar in AisleListView ([ae49a1e](https://github.com/Fenriz1349/MediStock/commit/ae49a1e474bd1890c50df50626cfb9ddcd9dbd94))
* add sendPasswordReset ([7c3ac73](https://github.com/Fenriz1349/MediStock/commit/7c3ac738b80d03afce752aff41f957eaa0eb6366))
* add SortingMenu ([7bfad45](https://github.com/Fenriz1349/MediStock/commit/7bfad45436f030de2e3891542a7f0887e439cbe3))
* add timestamp ordering ([40a4d6a](https://github.com/Fenriz1349/MediStock/commit/40a4d6aa2e9780b5b7720ce0c8d3145183331228))
* add Toasty display in MedicineDetailView, AllMedicinesView, AisleListView and ContentView ([0f5e485](https://github.com/Fenriz1349/MediStock/commit/0f5e48519b94c1322411dadb4122a9779896a482))
* add Toasty in UserView and AuthenticationView to display errorMessage ([4635353](https://github.com/Fenriz1349/MediStock/commit/463535321f166b74e40d884ce3352baf466b77fa))
* add ToastyContainer over ContentView ([a729335](https://github.com/Fenriz1349/MediStock/commit/a7293357ee73adaff1c3cef544cbc8e062ed6412))
* add UserView with logout and delete account, add it in tabview ([a9c7c18](https://github.com/Fenriz1349/MediStock/commit/a9c7c18e6e85f10e7c3473b75082f50f73aa99b1))
* addMedicine use new rule ([bd81755](https://github.com/Fenriz1349/MediStock/commit/bd81755afc16f811e71ffefd1bc23dd22ea837f8))
* display all NavigationTitle inline ([589f8df](https://github.com/Fenriz1349/MediStock/commit/589f8dfaee3fb6a4578a2d766f59d34bb2513e6c))
* hide elements from accessibility ([55da407](https://github.com/Fenriz1349/MediStock/commit/55da4077340c66c47af0301fe450eeb077b5a1fe))
* implement AccentListRow in all lists ([06fc6e1](https://github.com/Fenriz1349/MediStock/commit/06fc6e13eeeaa434e96cb27b0110762f4ded5d77))
* implement aisleStore in DIContainer and VM, add sanitizedAisle to prevent / in aislename, update PreviewHelper ([61f2b86](https://github.com/Fenriz1349/MediStock/commit/61f2b86528f807c03f15a4c20e185b2558b612bd))
* implement CustomTextFields and EmailPolicy in AuthenticationView ([b5a9350](https://github.com/Fenriz1349/MediStock/commit/b5a935060a04da735c61f02d692dca260dde7cc0))
* implement delete method in all VM, add swipe to delete and delete button in DetailView, disply alert on delete ([e11e667](https://github.com/Fenriz1349/MediStock/commit/e11e66774f093a9e656a8b6d64a89af85bda1c65))
* implement sorting menu in AllMedicinesView, change Layout ([aec8a51](https://github.com/Fenriz1349/MediStock/commit/aec8a5171ca92184c78300b4280aa89d6ac33da2))
* in AddMedicineView add cancel button, stock textfield starts now with empty fields ([441befa](https://github.com/Fenriz1349/MediStock/commit/441befad7e046bc77149e355204003262860a647))
* rework AuthenticationViewModel to catch error un AuthenticationError instead of print ([627b07a](https://github.com/Fenriz1349/MediStock/commit/627b07a7c8605ba2a9049f45c514913c5ace3fe9))
* Rework MedicineDetailView with update button, rework MedicineFormContent to receive argument instead of viewmodel ([65e2091](https://github.com/Fenriz1349/MediStock/commit/65e209151de898a8748c5f37ce24225e15f6b3ce))
* rework verifyReachable to throw error, implement networkMonitor ([19eccb7](https://github.com/Fenriz1349/MediStock/commit/19eccb7799976d03f79bd712f43c56e7dfa5b0b4))
* rework VM with error handlign and no try? ([2860fd4](https://github.com/Fenriz1349/MediStock/commit/2860fd496f139a855dea8a597918e7d2d77bd6ce))
* update observeMedicines to add ascending, add ascending / descending button in AllMedicineView ([de1b2b4](https://github.com/Fenriz1349/MediStock/commit/de1b2b4a6eeafe5c2a477a3d1162a93121c4ca2c))
* update recordAddition and recordDeletion details label ([2dab844](https://github.com/Fenriz1349/MediStock/commit/2dab8444fd93ef6cb38532f773a4763401626375))


### Bug Fixes

* add ci-skip.yml to prevent CI for bump version bot ([e99c69c](https://github.com/Fenriz1349/MediStock/commit/e99c69c4bec7d118a143cfdad098eb738c8534a4))
* add concurrency for flow ([77f3ef2](https://github.com/Fenriz1349/MediStock/commit/77f3ef2639b9596f5b054ee507261b938fa843e3))
* add parallel-testing-enabled and set simulator language to french in CI ([0befecc](https://github.com/Fenriz1349/MediStock/commit/0befecc8e7ac65c7efb0d93b4a75c365f50252be))
* add placement to .searchable to fix VO navigation ([232055c](https://github.com/Fenriz1349/MediStock/commit/232055c59540eaf319e758a8703ea1767bcf5413))
* fix alert in UserView ([f0bcdcc](https://github.com/Fenriz1349/MediStock/commit/f0bcdcc86ad332d68e1a964def0de5833c6eaea4))
* fix AppIcon ([4f18f1a](https://github.com/Fenriz1349/MediStock/commit/4f18f1ab4b71a80813cae9aee5a670e28eabbfea))
* fix catalogViewModel.listen() in ContentView ([d1b3d72](https://github.com/Fenriz1349/MediStock/commit/d1b3d729d75988c162d16b7ce3b489e46679e557))
* fix CI by removing localization tests ([07aab9b](https://github.com/Fenriz1349/MediStock/commit/07aab9b4f743a64f8917ef1a3ce3b8ebe079ee90))
* fix frame for loading overlay ([c59f94a](https://github.com/Fenriz1349/MediStock/commit/c59f94a33fd5aca1121b4b317de90ee096d3a3d8))
* fix NetworkMonitor ([001b491](https://github.com/Fenriz1349/MediStock/commit/001b491e0ade06cf4e074419dce3a980436a21d3))
* fix package destination ([93c1680](https://github.com/Fenriz1349/MediStock/commit/93c1680402cfb9cf5cae83bee1191d029e78d930))
* fix tests ([48b8614](https://github.com/Fenriz1349/MediStock/commit/48b8614b80c19094a34ceacd0fa8c626f779d8cd))
* fix validation rules in AddMedicineViewModel ([f25e41e](https://github.com/Fenriz1349/MediStock/commit/f25e41e04cdd5cd049fa4db7c866d92be58edbf6))
* in MedicineDetailView change  TextField for Text to actually display stock ([31f094d](https://github.com/Fenriz1349/MediStock/commit/31f094ddaf6b77fe3b8fbd4c285e52f3ab926dc2))
* stock buttons closing detail page ([c450b6e](https://github.com/Fenriz1349/MediStock/commit/c450b6e8e64d0dc5a9d0fc9459cb4911fb9ba1c4))

## [1.22.0](https://github.com/Fenriz1349/MediStock/compare/v1.21.0...v1.22.0) (2026-08-16)


### Features

* add FirestoreAisleStore, AisleSummary, AisleStoring and AisleStoringDouble ([0bb9a75](https://github.com/Fenriz1349/MediStock/commit/0bb9a7569192c2f342f9e69d13b2c2d726a339bb))
* add picker with aislesSummary in MedicineFormContent, add test ([f0e3291](https://github.com/Fenriz1349/MediStock/commit/f0e3291e402c850ca78bf0224457d3d09d3e329e))
* implement aisleStore in DIContainer and VM, add sanitizedAisle to prevent / in aislename, update PreviewHelper ([61f2b86](https://github.com/Fenriz1349/MediStock/commit/61f2b86528f807c03f15a4c20e185b2558b612bd))

## [1.21.0](https://github.com/Fenriz1349/MediStock/compare/v1.20.0...v1.21.0) (2026-08-14)


### Features

* add PaginationPolicy and lazy / pagination in every Views, update tests ([bd0c409](https://github.com/Fenriz1349/MediStock/commit/bd0c40945d0a8fc6ef3a09e33b2479f76ca98a22))

## [1.20.0](https://github.com/Fenriz1349/MediStock/compare/v1.19.0...v1.20.0) (2026-08-14)


### Features

* add dispatchQueue in FirebaseApp.configure() to handle it outside mainthread ([aa6f1bf](https://github.com/Fenriz1349/MediStock/commit/aa6f1bf1a597ea1d875a70dcee1af635e837cab6))
* add index filter for AisleMedicinesViewModel ([31f0697](https://github.com/Fenriz1349/MediStock/commit/31f06976dfd127112941db6745cb0d6702bd60f4))

## [1.19.0](https://github.com/Fenriz1349/MediStock/compare/v1.18.0...v1.19.0) (2026-08-14)


### Features

* add delete in MedicineStoring and recordDeletion in HistoryStoring ([8eea52f](https://github.com/Fenriz1349/MediStock/commit/8eea52fac2da32651a7c326bd5b105c788ae85d2))
* implement delete method in all VM, add swipe to delete and delete button in DetailView, disply alert on delete ([e11e667](https://github.com/Fenriz1349/MediStock/commit/e11e66774f093a9e656a8b6d64a89af85bda1c65))

## [1.18.0](https://github.com/Fenriz1349/MediStock/compare/v1.17.0...v1.18.0) (2026-08-14)


### Features

* add AccentListRow ([02f776a](https://github.com/Fenriz1349/MediStock/commit/02f776a2d21c5a3521a2d4c1fe6249e49eba24a8))
* add AccessibilityHandler, implement accessibilityLabel in all views ([94a1573](https://github.com/Fenriz1349/MediStock/commit/94a157300655e8dd15170879e02f6bfc74282d34))
* add AddMedicineView, change addRandomMedicine into functionnal addMedicine ([831a6e7](https://github.com/Fenriz1349/MediStock/commit/831a6e7f9f57392fc3b93977c5f7c417dbd82adb))
* add AddMedicineViewModel, Implement CustomTextFields in MedicineFormContent and AddMedicineView ([022e616](https://github.com/Fenriz1349/MediStock/commit/022e61675c2c249efd2b1bdae19406076780e682))
* add AisleCodeTest, remove cleanedAisle ([c84e37f](https://github.com/Fenriz1349/MediStock/commit/c84e37f2709aec879bced2d2bdd0f7fb48a4ffe2))
* add AisleLabel to handal localisation and label name, fix navigation ([dff3537](https://github.com/Fenriz1349/MediStock/commit/dff35373499ba90aa7a452667c6f67615d7cf2ea))
* add AisleListViewModel ([5e942f6](https://github.com/Fenriz1349/MediStock/commit/5e942f6267d4c216be38297b00ec80c3dd8a0156))
* add AisleMedicinesViewModel to handle specifically AisleMedicinesView ([578c2db](https://github.com/Fenriz1349/MediStock/commit/578c2db0f899fdfa0f159b1292977045732687e9))
* add AllMedicinesViewModel ([bca6e97](https://github.com/Fenriz1349/MediStock/commit/bca6e9762b5b4063dffaa148df6710860ab345b9))
* add AppButtonStyle ([ad6f6eb](https://github.com/Fenriz1349/MediStock/commit/ad6f6eb1257dd2e312b04d7810f7dac101866b97))
* add AppIcon, AccentColor ([49e9e32](https://github.com/Fenriz1349/MediStock/commit/49e9e3251343a66eb7aababf7a286a13813ad85d))
* add AppLogo and implement it in AuthenticationView, OfflineView ([91b3214](https://github.com/Fenriz1349/MediStock/commit/91b321437efb948512774641d8a3185455b229b3))
* add ascendent / descendent sorting in AisleListView ([8f5d708](https://github.com/Fenriz1349/MediStock/commit/8f5d708b171b71a1bfc4dd90d65dd086f4d565ae))
* add AuthenticationError and AuthenticationErrorMessage for localisation, add mapError in FirebaseAuthenticationService ([1ea58ad](https://github.com/Fenriz1349/MediStock/commit/1ea58ad82508e09dc46c418ccd12d1ce809db982))
* add CircleIconButtonStyle, use it for all circular buttons ([16c8977](https://github.com/Fenriz1349/MediStock/commit/16c89778d50f08dd8b1f1113f88e78d0a091ceeb))
* add currentUser in FirebaseAuthenticationService, implement actual FirestoreHistoryStore functions, remove authenticationVM from all view ([1d3af89](https://github.com/Fenriz1349/MediStock/commit/1d3af89125ee3ec3b7249d8cf217786b0249d452))
* add delete on medecine ([0bac8c2](https://github.com/Fenriz1349/MediStock/commit/0bac8c2846e3ffd797911a0e40fe702dbdb58e49))
* add delete on medecine ([406a724](https://github.com/Fenriz1349/MediStock/commit/406a724247b7caccdb6a7ee2c7529ffea4500590))
* add EmailPolicy and CustomTextfield package ([541462a](https://github.com/Fenriz1349/MediStock/commit/541462a7d4f8ddfd79ba15eee47c1b685e0910ac))
* add focusState on name for MedicineContent, and on email for AuthenticationView only in VO ([3b15415](https://github.com/Fenriz1349/MediStock/commit/3b154156c0c90553a05bcd5c1524da573af59654))
* add HistoryEntryLocalized and implement it in MedicineDetailHistorySection, rework MedicineDetailHistorySection ([d2b9aee](https://github.com/Fenriz1349/MediStock/commit/d2b9aee3e8e826621a2c1226263907573fb4a3c9))
* add isLoading in every VM / Views handling async ([d7b248a](https://github.com/Fenriz1349/MediStock/commit/d7b248a4ac80429bef3bf8e073a27abb1b266b73))
* add KeyboardToolBar to display close and validate buttons on every keyboard ([31b0db3](https://github.com/Fenriz1349/MediStock/commit/31b0db3d67d40434b321402b4f50cb52e026f203))
* add LoadingView and implement it ([aa726d0](https://github.com/Fenriz1349/MediStock/commit/aa726d0b78eaa78e49c85f1deb6916c41525758b))
* add mapError in FirestoreMedicineStore and FirestoreHistoryStore ([ebfc974](https://github.com/Fenriz1349/MediStock/commit/ebfc9745fb73562f15075aff58287b5e5af9e03e))
* add MedicineError and MedicineErrorMessage ([09c16b8](https://github.com/Fenriz1349/MediStock/commit/09c16b8e5ef57ec28fed24753f64569a19771df6))
* add MedicineFormContent ([6cfc181](https://github.com/Fenriz1349/MediStock/commit/6cfc181d12b31605a11b9d483a76d9bb426da766))
* add MedicineNameFormat and MedicineNameFormatTest ([9462ca7](https://github.com/Fenriz1349/MediStock/commit/9462ca77c4cc57da24f1181a674ebcbdbd0bc77b))
* add MedicinePolicy and MedicinePolicyTests ([5aead23](https://github.com/Fenriz1349/MediStock/commit/5aead23ce87ecccffb4aa49ceaa3249e57ee18ec))
* add NetworkMonitor and NetworkMonitoring ([63009ee](https://github.com/Fenriz1349/MediStock/commit/63009ee42b7bc89206cc22db3e8590e03b7f4336))
* add observeMedicines, AllMedicinesView use it for text search ([6372185](https://github.com/Fenriz1349/MediStock/commit/63721858b64e9ec85c821f023b553bbdd3e857d1))
* add OfflineView, rework ContentView and offlinemode ([eeae362](https://github.com/Fenriz1349/MediStock/commit/eeae362e0c43bd99ce1640a06e809fc79b8f2086))
* add password reset button in authentication view ([78166f8](https://github.com/Fenriz1349/MediStock/commit/78166f88499ebb2c56bfe9fa4e8b81aa7963ff23))
* add PasswordPolicy to handle password validation rules, PasswordRequirement to handle localisation ([1f2bac5](https://github.com/Fenriz1349/MediStock/commit/1f2bac5c7fb00fbf62919c0a61b1588aa9a6c62a))
* add PreviewHelper ([229d14e](https://github.com/Fenriz1349/MediStock/commit/229d14ec3effed6c792076372f7156677414b5bf))
* add public listner functions and refactor observe in a private concrete listener creator ([57bf18a](https://github.com/Fenriz1349/MediStock/commit/57bf18ac3fc4fac9034a8872961e40f7f751a0f8))
* add sanitizedStock ([7e4a8da](https://github.com/Fenriz1349/MediStock/commit/7e4a8da31e7c39273198131d213559188dde186a))
* add search bar in AisleListView ([ae49a1e](https://github.com/Fenriz1349/MediStock/commit/ae49a1e474bd1890c50df50626cfb9ddcd9dbd94))
* add sendPasswordReset ([7c3ac73](https://github.com/Fenriz1349/MediStock/commit/7c3ac738b80d03afce752aff41f957eaa0eb6366))
* add SortingMenu ([7bfad45](https://github.com/Fenriz1349/MediStock/commit/7bfad45436f030de2e3891542a7f0887e439cbe3))
* add timestamp ordering ([40a4d6a](https://github.com/Fenriz1349/MediStock/commit/40a4d6aa2e9780b5b7720ce0c8d3145183331228))
* add Toasty display in MedicineDetailView, AllMedicinesView, AisleListView and ContentView ([0f5e485](https://github.com/Fenriz1349/MediStock/commit/0f5e48519b94c1322411dadb4122a9779896a482))
* add Toasty in UserView and AuthenticationView to display errorMessage ([4635353](https://github.com/Fenriz1349/MediStock/commit/463535321f166b74e40d884ce3352baf466b77fa))
* add ToastyContainer over ContentView ([a729335](https://github.com/Fenriz1349/MediStock/commit/a7293357ee73adaff1c3cef544cbc8e062ed6412))
* add UserView with logout and delete account, add it in tabview ([a9c7c18](https://github.com/Fenriz1349/MediStock/commit/a9c7c18e6e85f10e7c3473b75082f50f73aa99b1))
* addMedicine use new rule ([bd81755](https://github.com/Fenriz1349/MediStock/commit/bd81755afc16f811e71ffefd1bc23dd22ea837f8))
* display all NavigationTitle inline ([589f8df](https://github.com/Fenriz1349/MediStock/commit/589f8dfaee3fb6a4578a2d766f59d34bb2513e6c))
* hide elements from accessibility ([55da407](https://github.com/Fenriz1349/MediStock/commit/55da4077340c66c47af0301fe450eeb077b5a1fe))
* implement AccentListRow in all lists ([06fc6e1](https://github.com/Fenriz1349/MediStock/commit/06fc6e13eeeaa434e96cb27b0110762f4ded5d77))
* implement CustomTextFields and EmailPolicy in AuthenticationView ([b5a9350](https://github.com/Fenriz1349/MediStock/commit/b5a935060a04da735c61f02d692dca260dde7cc0))
* implement sorting menu in AllMedicinesView, change Layout ([aec8a51](https://github.com/Fenriz1349/MediStock/commit/aec8a5171ca92184c78300b4280aa89d6ac33da2))
* in AddMedicineView add cancel button, stock textfield starts now with empty fields ([441befa](https://github.com/Fenriz1349/MediStock/commit/441befad7e046bc77149e355204003262860a647))
* rework AuthenticationViewModel to catch error un AuthenticationError instead of print ([627b07a](https://github.com/Fenriz1349/MediStock/commit/627b07a7c8605ba2a9049f45c514913c5ace3fe9))
* Rework MedicineDetailView with update button, rework MedicineFormContent to receive argument instead of viewmodel ([65e2091](https://github.com/Fenriz1349/MediStock/commit/65e209151de898a8748c5f37ce24225e15f6b3ce))
* rework verifyReachable to throw error, implement networkMonitor ([19eccb7](https://github.com/Fenriz1349/MediStock/commit/19eccb7799976d03f79bd712f43c56e7dfa5b0b4))
* rework VM with error handlign and no try? ([2860fd4](https://github.com/Fenriz1349/MediStock/commit/2860fd496f139a855dea8a597918e7d2d77bd6ce))
* update observeMedicines to add ascending, add ascending / descending button in AllMedicineView ([de1b2b4](https://github.com/Fenriz1349/MediStock/commit/de1b2b4a6eeafe5c2a477a3d1162a93121c4ca2c))
* update recordAddition and recordDeletion details label ([2dab844](https://github.com/Fenriz1349/MediStock/commit/2dab8444fd93ef6cb38532f773a4763401626375))


### Bug Fixes

* add ci-skip.yml to prevent CI for bump version bot ([e99c69c](https://github.com/Fenriz1349/MediStock/commit/e99c69c4bec7d118a143cfdad098eb738c8534a4))
* add concurrency for flow ([77f3ef2](https://github.com/Fenriz1349/MediStock/commit/77f3ef2639b9596f5b054ee507261b938fa843e3))
* add parallel-testing-enabled and set simulator language to french in CI ([0befecc](https://github.com/Fenriz1349/MediStock/commit/0befecc8e7ac65c7efb0d93b4a75c365f50252be))
* add placement to .searchable to fix VO navigation ([232055c](https://github.com/Fenriz1349/MediStock/commit/232055c59540eaf319e758a8703ea1767bcf5413))
* fix alert in UserView ([f0bcdcc](https://github.com/Fenriz1349/MediStock/commit/f0bcdcc86ad332d68e1a964def0de5833c6eaea4))
* fix AppIcon ([4f18f1a](https://github.com/Fenriz1349/MediStock/commit/4f18f1ab4b71a80813cae9aee5a670e28eabbfea))
* fix catalogViewModel.listen() in ContentView ([d1b3d72](https://github.com/Fenriz1349/MediStock/commit/d1b3d729d75988c162d16b7ce3b489e46679e557))
* fix CI by removing localization tests ([07aab9b](https://github.com/Fenriz1349/MediStock/commit/07aab9b4f743a64f8917ef1a3ce3b8ebe079ee90))
* fix frame for loading overlay ([c59f94a](https://github.com/Fenriz1349/MediStock/commit/c59f94a33fd5aca1121b4b317de90ee096d3a3d8))
* fix NetworkMonitor ([001b491](https://github.com/Fenriz1349/MediStock/commit/001b491e0ade06cf4e074419dce3a980436a21d3))
* fix package destination ([93c1680](https://github.com/Fenriz1349/MediStock/commit/93c1680402cfb9cf5cae83bee1191d029e78d930))
* fix tests ([48b8614](https://github.com/Fenriz1349/MediStock/commit/48b8614b80c19094a34ceacd0fa8c626f779d8cd))
* fix validation rules in AddMedicineViewModel ([f25e41e](https://github.com/Fenriz1349/MediStock/commit/f25e41e04cdd5cd049fa4db7c866d92be58edbf6))
* in MedicineDetailView change  TextField for Text to actually display stock ([31f094d](https://github.com/Fenriz1349/MediStock/commit/31f094ddaf6b77fe3b8fbd4c285e52f3ab926dc2))
* stock buttons closing detail page ([c450b6e](https://github.com/Fenriz1349/MediStock/commit/c450b6e8e64d0dc5a9d0fc9459cb4911fb9ba1c4))

## [1.16.0](https://github.com/Fenriz1349/MediStock/compare/v1.15.0...v1.16.0) (2026-08-13)


### Features

* add AccentListRow ([02f776a](https://github.com/Fenriz1349/MediStock/commit/02f776a2d21c5a3521a2d4c1fe6249e49eba24a8))
* add AppButtonStyle ([ad6f6eb](https://github.com/Fenriz1349/MediStock/commit/ad6f6eb1257dd2e312b04d7810f7dac101866b97))
* add AppIcon, AccentColor ([49e9e32](https://github.com/Fenriz1349/MediStock/commit/49e9e3251343a66eb7aababf7a286a13813ad85d))
* add AppLogo and implement it in AuthenticationView, OfflineView ([91b3214](https://github.com/Fenriz1349/MediStock/commit/91b321437efb948512774641d8a3185455b229b3))
* add HistoryEntryLocalized and implement it in MedicineDetailHistorySection, rework MedicineDetailHistorySection ([d2b9aee](https://github.com/Fenriz1349/MediStock/commit/d2b9aee3e8e826621a2c1226263907573fb4a3c9))
* add LoadingView and implement it ([aa726d0](https://github.com/Fenriz1349/MediStock/commit/aa726d0b78eaa78e49c85f1deb6916c41525758b))
* add sanitizedStock ([7e4a8da](https://github.com/Fenriz1349/MediStock/commit/7e4a8da31e7c39273198131d213559188dde186a))
* add sendPasswordReset ([7c3ac73](https://github.com/Fenriz1349/MediStock/commit/7c3ac738b80d03afce752aff41f957eaa0eb6366))
* add SortingMenu ([7bfad45](https://github.com/Fenriz1349/MediStock/commit/7bfad45436f030de2e3891542a7f0887e439cbe3))
* display all NavigationTitle inline ([589f8df](https://github.com/Fenriz1349/MediStock/commit/589f8dfaee3fb6a4578a2d766f59d34bb2513e6c))
* implement AccentListRow in all lists ([06fc6e1](https://github.com/Fenriz1349/MediStock/commit/06fc6e13eeeaa434e96cb27b0110762f4ded5d77))
* implement sorting menu in AllMedicinesView, change Layout ([aec8a51](https://github.com/Fenriz1349/MediStock/commit/aec8a5171ca92184c78300b4280aa89d6ac33da2))


### Bug Fixes

* add parallel-testing-enabled and set simulator language to french in CI ([0befecc](https://github.com/Fenriz1349/MediStock/commit/0befecc8e7ac65c7efb0d93b4a75c365f50252be))
* fix AppIcon ([4f18f1a](https://github.com/Fenriz1349/MediStock/commit/4f18f1ab4b71a80813cae9aee5a670e28eabbfea))
* fix CI by removing localization tests ([07aab9b](https://github.com/Fenriz1349/MediStock/commit/07aab9b4f743a64f8917ef1a3ce3b8ebe079ee90))
* fix frame for loading overlay ([c59f94a](https://github.com/Fenriz1349/MediStock/commit/c59f94a33fd5aca1121b4b317de90ee096d3a3d8))

## [1.15.0](https://github.com/Fenriz1349/MediStock/compare/v1.14.0...v1.15.0) (2026-08-11)


### Features

* add AddMedicineViewModel, Implement CustomTextFields in MedicineFormContent and AddMedicineView ([022e616](https://github.com/Fenriz1349/MediStock/commit/022e61675c2c249efd2b1bdae19406076780e682))
* add EmailPolicy and CustomTextfield package ([541462a](https://github.com/Fenriz1349/MediStock/commit/541462a7d4f8ddfd79ba15eee47c1b685e0910ac))
* add KeyboardToolBar to display close and validate buttons on every keyboard ([31b0db3](https://github.com/Fenriz1349/MediStock/commit/31b0db3d67d40434b321402b4f50cb52e026f203))
* add MedicinePolicy and MedicinePolicyTests ([5aead23](https://github.com/Fenriz1349/MediStock/commit/5aead23ce87ecccffb4aa49ceaa3249e57ee18ec))
* implement CustomTextFields and EmailPolicy in AuthenticationView ([b5a9350](https://github.com/Fenriz1349/MediStock/commit/b5a935060a04da735c61f02d692dca260dde7cc0))
* Rework MedicineDetailView with update button, rework MedicineFormContent to receive argument instead of viewmodel ([65e2091](https://github.com/Fenriz1349/MediStock/commit/65e209151de898a8748c5f37ce24225e15f6b3ce))


### Bug Fixes

* fix NetworkMonitor ([001b491](https://github.com/Fenriz1349/MediStock/commit/001b491e0ade06cf4e074419dce3a980436a21d3))
* fix validation rules in AddMedicineViewModel ([f25e41e](https://github.com/Fenriz1349/MediStock/commit/f25e41e04cdd5cd049fa4db7c866d92be58edbf6))

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
