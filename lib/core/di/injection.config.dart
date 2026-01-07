// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:get_it/get_it.dart' as _i174;
import 'package:google_sign_in/google_sign_in.dart' as _i116;
import 'package:injectable/injectable.dart' as _i526;
import 'package:resq/core/di/firebase_module.dart' as _i431;
import 'package:resq/core/services/emergency_number_service.dart' as _i503;
import 'package:resq/features/auth/data/datasources/auth_remote_datasource.dart'
    as _i1056;
import 'package:resq/features/auth/data/repositories/auth_repository_impl.dart'
    as _i124;
import 'package:resq/features/auth/domain/repositories/auth_repository.dart'
    as _i474;
import 'package:resq/features/auth/domain/usecases/get_current_user_usecase.dart'
    as _i998;
import 'package:resq/features/auth/domain/usecases/google_sign_in_usecase.dart'
    as _i795;
import 'package:resq/features/auth/domain/usecases/login_usecase.dart' as _i281;
import 'package:resq/features/auth/domain/usecases/logout_usecase.dart'
    as _i940;
import 'package:resq/features/auth/domain/usecases/send_phone_otp_usecase.dart'
    as _i602;
import 'package:resq/features/auth/domain/usecases/signup_usecase.dart'
    as _i183;
import 'package:resq/features/auth/domain/usecases/verify_phone_otp_usecase.dart'
    as _i575;
import 'package:resq/features/func/data/datasources/address_remote_datasource.dart'
    as _i9;
import 'package:resq/features/func/data/datasources/community_remote_datasource.dart'
    as _i455;
import 'package:resq/features/func/data/datasources/dangerous_zone_remote_datasource.dart'
    as _i999;
import 'package:resq/features/func/data/datasources/emergency_contact_local_datasource.dart'
    as _i122;
import 'package:resq/features/func/data/datasources/emergency_contact_remote_datasource.dart'
    as _i691;
import 'package:resq/features/func/data/datasources/emergency_number_remote_datasource.dart'
    as _i919;
import 'package:resq/features/func/data/datasources/group_remote_datasource.dart'
    as _i318;
import 'package:resq/features/func/data/datasources/private_emergency_message_remote_datasource.dart'
    as _i740;
import 'package:resq/features/func/data/datasources/safe_zone_remote_datasource.dart'
    as _i845;
import 'package:resq/features/func/data/repositories/address_repository_impl.dart'
    as _i36;
import 'package:resq/features/func/data/repositories/community_repository_impl.dart'
    as _i198;
import 'package:resq/features/func/data/repositories/dangerous_zone_repository_impl.dart'
    as _i1055;
import 'package:resq/features/func/data/repositories/emergency_contact_repository_impl.dart'
    as _i752;
import 'package:resq/features/func/data/repositories/emergency_number_repository_impl.dart'
    as _i849;
import 'package:resq/features/func/data/repositories/group_repository_impl.dart'
    as _i835;
import 'package:resq/features/func/data/repositories/private_emergency_message_repository_impl.dart'
    as _i867;
import 'package:resq/features/func/data/repositories/safe_zone_repository_impl.dart'
    as _i1072;
import 'package:resq/features/func/domain/repositories/address_repository.dart'
    as _i63;
import 'package:resq/features/func/domain/repositories/community_repository.dart'
    as _i690;
import 'package:resq/features/func/domain/repositories/dangerous_zone_repository.dart'
    as _i24;
import 'package:resq/features/func/domain/repositories/emergency_contact_repository.dart'
    as _i1073;
import 'package:resq/features/func/domain/repositories/emergency_number_repository.dart'
    as _i773;
import 'package:resq/features/func/domain/repositories/group_repository.dart'
    as _i1043;
import 'package:resq/features/func/domain/repositories/private_emergency_message_repository.dart'
    as _i179;
import 'package:resq/features/func/domain/repositories/safe_zone_repository.dart'
    as _i561;
import 'package:resq/features/func/domain/usecases/add_member_to_group_usecase.dart'
    as _i257;
import 'package:resq/features/func/domain/usecases/clear_emergency_number_usecase.dart'
    as _i461;
import 'package:resq/features/func/domain/usecases/create_group_usecase.dart'
    as _i16;
import 'package:resq/features/func/domain/usecases/delete_emergency_contact_usecase.dart'
    as _i59;
import 'package:resq/features/func/domain/usecases/delete_group_message_usecase.dart'
    as _i206;
import 'package:resq/features/func/domain/usecases/delete_message_usecase.dart'
    as _i404;
import 'package:resq/features/func/domain/usecases/get_address_usecase.dart'
    as _i786;
import 'package:resq/features/func/domain/usecases/get_emergency_contact_usecase.dart'
    as _i938;
import 'package:resq/features/func/domain/usecases/get_emergency_number_usecase.dart'
    as _i574;
import 'package:resq/features/func/domain/usecases/get_user_groups_usecase.dart'
    as _i8;
import 'package:resq/features/func/domain/usecases/join_group_usecase.dart'
    as _i887;
import 'package:resq/features/func/domain/usecases/leave_group_usecase.dart'
    as _i655;
import 'package:resq/features/func/domain/usecases/mark_private_message_read_usecase.dart'
    as _i848;
import 'package:resq/features/func/domain/usecases/save_address_usecase.dart'
    as _i956;
import 'package:resq/features/func/domain/usecases/save_emergency_contact_usecase.dart'
    as _i601;
import 'package:resq/features/func/domain/usecases/send_group_message_usecase.dart'
    as _i40;
import 'package:resq/features/func/domain/usecases/send_message_usecase.dart'
    as _i256;
import 'package:resq/features/func/domain/usecases/send_private_emergency_message_usecase.dart'
    as _i828;
import 'package:resq/features/func/domain/usecases/set_emergency_number_usecase.dart'
    as _i464;
import 'package:resq/features/func/domain/usecases/stream_group_messages_usecase.dart'
    as _i653;
import 'package:resq/features/func/domain/usecases/stream_messages_usecase.dart'
    as _i491;
import 'package:resq/features/func/domain/usecases/stream_private_emergency_messages_usecase.dart'
    as _i5;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final firebaseModule = _$FirebaseModule();
    gh.lazySingleton<_i59.FirebaseAuth>(() => firebaseModule.firebaseAuth);
    gh.lazySingleton<_i974.FirebaseFirestore>(() => firebaseModule.firestore);
    gh.lazySingleton<_i116.GoogleSignIn>(() => firebaseModule.googleSignIn);
    gh.lazySingleton<_i122.EmergencyContactLocalDataSource>(
        () => _i122.EmergencyContactLocalDataSourceImpl());
    gh.lazySingleton<_i919.EmergencyNumberRemoteDataSource>(() =>
        _i919.EmergencyNumberRemoteDataSourceImpl(
            gh<_i974.FirebaseFirestore>()));
    gh.lazySingleton<_i455.CommunityRemoteDataSource>(() =>
        _i455.CommunityRemoteDataSourceImpl(gh<_i974.FirebaseFirestore>()));
    gh.lazySingleton<_i1056.AuthRemoteDataSource>(
        () => _i1056.AuthRemoteDataSourceImpl(
              gh<_i59.FirebaseAuth>(),
              gh<_i116.GoogleSignIn>(),
              gh<_i974.FirebaseFirestore>(),
            ));
    gh.lazySingleton<_i999.DangerousZoneRemoteDataSource>(() =>
        _i999.DangerousZoneRemoteDataSourceImpl(gh<_i974.FirebaseFirestore>()));
    gh.lazySingleton<_i691.EmergencyContactRemoteDataSource>(() =>
        _i691.EmergencyContactRemoteDataSourceImpl(
            gh<_i974.FirebaseFirestore>()));
    gh.lazySingleton<_i318.GroupRemoteDataSource>(
        () => _i318.GroupRemoteDataSourceImpl(gh<_i974.FirebaseFirestore>()));
    gh.lazySingleton<_i740.PrivateEmergencyMessageRemoteDataSource>(() =>
        _i740.PrivateEmergencyMessageRemoteDataSourceImpl(
            gh<_i974.FirebaseFirestore>()));
    gh.lazySingleton<_i690.CommunityRepository>(() =>
        _i198.CommunityRepositoryImpl(gh<_i455.CommunityRemoteDataSource>()));
    gh.lazySingleton<_i9.AddressRemoteDataSource>(
        () => _i9.AddressRemoteDataSourceImpl(gh<_i974.FirebaseFirestore>()));
    gh.lazySingleton<_i845.SafeZoneRemoteDataSource>(() =>
        _i845.SafeZoneRemoteDataSourceImpl(gh<_i974.FirebaseFirestore>()));
    gh.lazySingleton<_i773.EmergencyNumberRepository>(() =>
        _i849.EmergencyNumberRepositoryImpl(
            gh<_i919.EmergencyNumberRemoteDataSource>()));
    gh.factory<_i404.DeleteMessageUseCase>(
        () => _i404.DeleteMessageUseCase(gh<_i690.CommunityRepository>()));
    gh.factory<_i256.SendMessageUseCase>(
        () => _i256.SendMessageUseCase(gh<_i690.CommunityRepository>()));
    gh.factory<_i491.StreamMessagesUseCase>(
        () => _i491.StreamMessagesUseCase(gh<_i690.CommunityRepository>()));
    gh.lazySingleton<_i474.AuthRepository>(() => _i124.AuthRepositoryImpl(
          gh<_i1056.AuthRemoteDataSource>(),
          gh<_i974.FirebaseFirestore>(),
        ));
    gh.lazySingleton<_i1073.EmergencyContactRepository>(
        () => _i752.EmergencyContactRepositoryImpl(
              gh<_i122.EmergencyContactLocalDataSource>(),
              gh<_i691.EmergencyContactRemoteDataSource>(),
            ));
    gh.factory<_i59.DeleteEmergencyContactUseCase>(() =>
        _i59.DeleteEmergencyContactUseCase(
            gh<_i1073.EmergencyContactRepository>()));
    gh.factory<_i938.GetEmergencyContactsUseCase>(() =>
        _i938.GetEmergencyContactsUseCase(
            gh<_i1073.EmergencyContactRepository>()));
    gh.factory<_i601.AddEmergencyContactUseCase>(() =>
        _i601.AddEmergencyContactUseCase(
            gh<_i1073.EmergencyContactRepository>()));
    gh.lazySingleton<_i63.AddressRepository>(
        () => _i36.AddressRepositoryImpl(gh<_i9.AddressRemoteDataSource>()));
    gh.lazySingleton<_i561.SafeZoneRepository>(() =>
        _i1072.SafeZoneRepositoryImpl(gh<_i845.SafeZoneRemoteDataSource>()));
    gh.lazySingleton<_i179.PrivateEmergencyMessageRepository>(() =>
        _i867.PrivateEmergencyMessageRepositoryImpl(
            gh<_i740.PrivateEmergencyMessageRemoteDataSource>()));
    gh.lazySingleton<_i1043.GroupRepository>(
        () => _i835.GroupRepositoryImpl(gh<_i318.GroupRemoteDataSource>()));
    gh.lazySingleton<_i24.DangerousZoneRepository>(() =>
        _i1055.DangerousZoneRepositoryImpl(
            gh<_i999.DangerousZoneRemoteDataSource>()));
    gh.factory<_i786.GetAddressUseCase>(() => _i786.GetAddressUseCase(
          gh<_i63.AddressRepository>(),
          gh<_i59.FirebaseAuth>(),
        ));
    gh.factory<_i956.SaveAddressUseCase>(() => _i956.SaveAddressUseCase(
          gh<_i63.AddressRepository>(),
          gh<_i59.FirebaseAuth>(),
        ));
    gh.factory<_i461.ClearEmergencyNumberUseCase>(() =>
        _i461.ClearEmergencyNumberUseCase(
            gh<_i773.EmergencyNumberRepository>()));
    gh.factory<_i574.GetEmergencyNumberUseCase>(() =>
        _i574.GetEmergencyNumberUseCase(gh<_i773.EmergencyNumberRepository>()));
    gh.factory<_i464.SetEmergencyNumberUseCase>(() =>
        _i464.SetEmergencyNumberUseCase(gh<_i773.EmergencyNumberRepository>()));
    gh.factory<_i848.MarkPrivateMessageReadUseCase>(() =>
        _i848.MarkPrivateMessageReadUseCase(
            gh<_i179.PrivateEmergencyMessageRepository>()));
    gh.factory<_i828.SendPrivateEmergencyMessageUseCase>(() =>
        _i828.SendPrivateEmergencyMessageUseCase(
            gh<_i179.PrivateEmergencyMessageRepository>()));
    gh.factory<_i5.StreamPrivateEmergencyMessagesUseCase>(() =>
        _i5.StreamPrivateEmergencyMessagesUseCase(
            gh<_i179.PrivateEmergencyMessageRepository>()));
    gh.factory<_i998.GetCurrentUserUseCase>(
        () => _i998.GetCurrentUserUseCase(gh<_i474.AuthRepository>()));
    gh.factory<_i795.GoogleSignInUseCase>(
        () => _i795.GoogleSignInUseCase(gh<_i474.AuthRepository>()));
    gh.factory<_i281.LoginUseCase>(
        () => _i281.LoginUseCase(gh<_i474.AuthRepository>()));
    gh.factory<_i940.LogoutUseCase>(
        () => _i940.LogoutUseCase(gh<_i474.AuthRepository>()));
    gh.factory<_i602.SendPhoneOtpUseCase>(
        () => _i602.SendPhoneOtpUseCase(gh<_i474.AuthRepository>()));
    gh.factory<_i183.SignupUseCase>(
        () => _i183.SignupUseCase(gh<_i474.AuthRepository>()));
    gh.factory<_i575.VerifyPhoneOtpUseCase>(
        () => _i575.VerifyPhoneOtpUseCase(gh<_i474.AuthRepository>()));
    gh.factory<_i257.AddMemberToGroupUseCase>(
        () => _i257.AddMemberToGroupUseCase(gh<_i1043.GroupRepository>()));
    gh.factory<_i16.CreateGroupUseCase>(
        () => _i16.CreateGroupUseCase(gh<_i1043.GroupRepository>()));
    gh.factory<_i206.DeleteGroupMessageUseCase>(
        () => _i206.DeleteGroupMessageUseCase(gh<_i1043.GroupRepository>()));
    gh.factory<_i8.GetUserGroupsUseCase>(
        () => _i8.GetUserGroupsUseCase(gh<_i1043.GroupRepository>()));
    gh.factory<_i887.JoinGroupUseCase>(
        () => _i887.JoinGroupUseCase(gh<_i1043.GroupRepository>()));
    gh.factory<_i655.LeaveGroupUseCase>(
        () => _i655.LeaveGroupUseCase(gh<_i1043.GroupRepository>()));
    gh.factory<_i40.SendGroupMessageUseCase>(
        () => _i40.SendGroupMessageUseCase(gh<_i1043.GroupRepository>()));
    gh.factory<_i653.StreamGroupMessagesUseCase>(
        () => _i653.StreamGroupMessagesUseCase(gh<_i1043.GroupRepository>()));
    gh.lazySingleton<_i503.EmergencyNumberService>(() =>
        _i503.EmergencyNumberServiceImpl(
            gh<_i574.GetEmergencyNumberUseCase>()));
    return this;
  }
}

class _$FirebaseModule extends _i431.FirebaseModule {}
