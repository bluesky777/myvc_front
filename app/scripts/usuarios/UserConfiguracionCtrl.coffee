angular.module('myvcFrontApp')
.controller('UserConfiguracionCtrl', ['$scope', '$http', 'Restangular', '$state', '$rootScope', 'AuthService', 'Perfil', 'App', ($scope, $http, Restangular, $state, $rootScope, AuthService, Perfil, App) ->

	AuthService.verificar_acceso()

	$scope.data = {} # Para el popup del Datapicker
	$scope.comprobando = false
	$scope.mostrarErrorUsername = false
	$scope.mostrarErrorPassword = false
	$scope.canSaveUsername = false

	$scope.newusername = ''
	$scope.passantiguo = ''
	$scope.newpass = ''
	$scope.newpassverif = ''
	$scope.status = { passCambiado: false } # Para cerrar tab cuando se cambie el password

	$scope.nombresdeusuario=[]

	Restangular.all('perfiles/usernames').getList().then((r)->
		$scope.nombresdeusuario = r
	, (r2)->
		console.log 'No se trajeron los nombres de usuario', r2
	)

	$scope.$watch 'newusername', (oldv, newv)->
		console.log 'oldv, newv', oldv, newv

	$scope.comprobarusername = (newusername)->

		$scope.canSaveUsername = false
		$scope.comprobando = true

		if newusername.username
			newusername = newusername.username
		if newusername == $scope.perfilactual.username
			$scope.toastr.warning 'Copia un nombre de usuario diferente al que ya tienes'
			$scope.comprobando = false
			return
		if newusername == ''
			$scope.toastr.warning 'Debes copiar un nombre de usuario.'
			$scope.comprobando = false
			return

		Restangular.all('perfiles/comprobarusername/'+newusername).getList().then((r)->
			
			if r[0].existe
				$scope.toastr.warning 'Nombre de usuario ya en uso.'
				$scope.mostrarErrorUsername = true
			else
				$scope.mostrarErrorUsername = false
				$scope.canSaveUsername = true
			$scope.comprobando = false
		, (r2)->
			console.log 'No se trajeron los nombres de usuario', r2
			$scope.comprobando = false
		)

	$scope.guardar = ()->
		$scope.canSaveUsername = false

		datos = 
			nombres:	$scope.perfilactual.nombres
			apellidos:	$scope.perfilactual.apellidos
			sexo:		$scope.perfilactual.sexo
			fecha_nac:	$scope.perfilactual.fecha_nac
			celular:	$scope.perfilactual.celular
			tipo:		$scope.perfilactual.tipo
			email_persona:	$scope.perfilactual.email_persona

		Restangular.one('perfiles/update', $scope.perfilactual.persona_id).customPUT(datos).then((r)->
			console.log 'Datos guardados, ', r
			$scope.toastr.success 'Datos guardados'
		, (r2)->
			console.log 'No se pudo guardar cambios, ', r2
			$scope.toastr.error 'Datos NO guardados', 'Problema'
			$scope.canSaveUsername = true
		)

	$scope.CambiarUsername = (newusername)->

		Restangular.one('perfiles/guardar-username', $scope.perfilactual.user_id).customPUT({'username':newusername}).then((r)->
			console.log 'Nombre de usuario guardado, ', r
			$scope.toastr.success 'Nombre de usuario guardado'
			Perfil.User().username = newusername
			$scope.$emit 'cambianImgs', {username: newusername}
		, (r2)->
			console.log 'No se pudo guardar nombre de usuario, ', r2
			$scope.toastr.error 'Nombre de usuario NO guardado', 'Problema'
		)

	$scope.CambiarPass = (newpass, newpassverif, passantiguo)->

		if newpass not in [newpassverif]
			$scope.toastr.warning 'Las contraseñas no coinciden'
			return
		if newpass.length < 4
			$scope.toastr.warning 'La contraseña debe tener mínimo 4 caracteres. Sin espacios ni Ñ ni tildes.'
			return
		
		$scope.cambiandoPass = true # Bloqueamos el botón temporalmente

		datos = {'password':newpassverif, 'oldpassword': passantiguo }


		Restangular.one('perfiles/cambiarpassword', $scope.perfilactual.user_id).customPUT(datos).then((r)->
			console.log 'Contraseña cambiada, ', r
			$scope.toastr.success 'Contraseña cambiada.'
			$scope.status.passCambiado = false
			$scope.cambiandoPass = false
		, (r2)->
			if r2.$error
			
				if r2.error.message == 'Contraseña antigua es incorrecta'
					$scope.toastr.warning r2.error.message
				else
					console.log 'No se pudo cambiar la contraseña, ', r2
					$scope.toastr.error 'No se pudo cambiar la contraseña.'
			else
				$scope.toastr.error 'No se pudo cambiar la contraseña.'

			$scope.cambiandoPass = false
		)

	$scope.CambiarCorreoRestore = ()->

		datos = { 'email_restore': $scope.email_restore }

		console.log datos
		Restangular.one('perfiles/cambiaremailrestore', $scope.perfilactual.user_id).customPUT(datos).then((r)->
			console.log 'Contraseña cambiada, ', r
			$scope.toastr.success 'Contraseña cambiada.'
		, (r2)->
			console.log 'No se pudo cambiar la contraseña, ', r2
			$scope.toastr.error 'No se pudo cambiar la contraseña', 'Problema'
		)

])

