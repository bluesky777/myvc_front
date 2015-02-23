angular.module('myvcFrontApp')

.factory('AuthService', ['Restangular', '$state', '$http', '$cookies', 'Perfil', '$rootScope', 'AUTH_EVENTS', '$q', '$filter', (Restangular, $state, $http, $cookies, Perfil, $rootScope, AUTH_EVENTS, $q, $filter)->
	authService = {}

	authService.verificar = ()->
		d = $q.defer();

		if Perfil.User().user_id
			d.resolve Perfil.User()
		else
			if $cookies.xtoken
				if $cookies.xtoken != undefined and $cookies.xtoken != 'undefined'  and $cookies.xtoken != '[object Object]'
					authService.login_from_token().then((usuario)->
						Perfil.setUser usuario
						d.resolve usuario
					, (r2)->
						d.reject r2
					)
				else
					console.log 'Token mal estructurado: ', $cookies.xtoken
					authService.borrarToken()
					d.reject 'Token mal estructurado.'
			else
				console.log 'No hay token'
				d.resolve 'No hay token.'
				$state.go 'login'
				#$rootScope.$broadcast(AUTH_EVENTS.notAuthenticated)
		return d.promise


	authService.verificar_acceso = ()->
		if !Perfil.User().user_id
			$state.go 'login'
		next = $state.current
		console.log 'Verficar accesso: ', $state.current, next.data
		if next.data.needed_permissions
			needed_permissions = next.data.needed_permissions 
			console.log 'needed_permissions: ', needed_permissions, next

			if (!authService.isAuthorized(needed_permissions))
				event.preventDefault()
				console.log 'No tiene permisos, y... '
				
				$rootScope.lastState = next.name
				if (authService.isAuthenticated())
					# user is not allowed
					$rootScope.$broadcast(AUTH_EVENTS.notAuthorized)
					console.log '...está Autenticado.'
				else
					# user is not logged in
					#$rootScope.$broadcast(AUTH_EVENTS.notAuthenticated)
					console.log '...NO está Autenticado.'
					$state.transitionTo 'login'
		



	authService.login_credentials = (credentials)->

		d = $q.defer();

		authService.borrarToken()

		Restangular.one('login').post('', credentials).then((user)->
			#debugger
			if user.token
				$cookies.xtoken = user.token
				
				$http.defaults.headers.common['Authorization'] = 'Bearer ' + $cookies.xtoken
				
				Perfil.setUser user

				console.log 'Usuario traido: ', user
				
				$rootScope.$broadcast AUTH_EVENTS.loginSuccess
				d.resolve user
			else
				console.log 'No se trajo un token en el login.', user
				$rootScope.$broadcast AUTH_EVENTS.loginFailed
				d.reject 'Error en login'


		, (r2)->
			console.log 'No se pudo loguear. ', r2
			$rootScope.$broadcast AUTH_EVENTS.loginFailed
			d.reject 'Error en login'
		)
		return d.promise


	authService.login_from_token = ()->

		d = $q.defer();

		$http.defaults.headers.common['Authorization'] = 'Bearer ' + $cookies.xtoken

		login = Restangular.one('login').post().then((usuario)->

			$rootScope.$broadcast(AUTH_EVENTS.loginSuccess);
			d.resolve usuario

		, (r2)->
			console.log 'No se pudo loguear con token. ', r2
			d.reject 'Error en login con token.'
			#$rootScope.$broadcast AUTH_EVENTS.loginFailed
		)
		return d.promise


	authService.logout = (credentials)->
		Restangular.one('logout').get();
		delete $http.defaults.headers.common['Authorization']
		delete $cookies['xtoken']
		$state.transitionTo 'login'

	authService.isAuthenticated = ()->
		return !!Perfil.User().user_id;

	authService.isAuthorized = (neededPermissions)->
		console.log 'Perfil.User().is_superuser', Perfil.User().is_superuser
		if Perfil.User().is_superuser ==1
			return true

		if (!angular.isArray(neededPermissions))
			neededPermissions = [neededPermissions]

		if (!angular.isArray(Perfil.User().perms))
			if neededPermissions.length > 0
				return true;
			else
				return false;

		newArr = []
		_.each(neededPermissions, (elem)->
			if (Perfil.User().perms.indexOf(elem)) != -1
				newArr.push elem
		)
		console.log 'Perfil.User().perms: ' , Perfil.User().perms, neededPermissions, newArr, newArr.length > 0
		return (authService.isAuthenticated() and (newArr.length > 0))

	authService.borrarToken = ()->
		delete $cookies.xtoken
		delete $http.defaults.headers.common['Authorization']

	authService.hasRoleOrPerm = (ReqRoles, RedPermis)->
		if (!angular.isArray(ReqRoles))
			if ReqRoles
				ReqRoles = [ReqRoles]
			else
				return false;

		rolesFound = []
		
		_.each(ReqRoles, (elem)->
			rolesFoundTemp = $filter('filter')(Perfil.User().roles, {name: elem})

			if rolesFoundTemp.length > 0
				rolesFound.push elem
		)
		return (rolesFound.length > 0)



	return authService;
])
