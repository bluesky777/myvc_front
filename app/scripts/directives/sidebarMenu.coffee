angular.module('myvcFrontApp')

.directive('sidebarMenu',['$rootScope', 'AuthService', '$http', '$uibModal', 'Perfil', 'ProfesoresServ', '$window', '$state', ($rootScope, AuthService, $http, $modal, Perfil, ProfesoresServ, $window, $state)->

	restrict: 'E'
	replace: true
	templateUrl: "==directives/sidebarMenu.tpl.html"
	scope:
		cargando: "="

	link: (scope, iElem, iAttrs)->
		# Debo agregar la clase .loading-inactive para que desaparezca el loader de la pantalla.
		# y eso lo puedo hacer con el ng-if

		scope.$watch(()->
			return $window.innerWidth
		, (value)->
			#console.log 'Ancho de la $window en sidebarMenu', value
			if value > 880
				iElem.removeClass('hide');
			else
				iElem.addClass('hide');
			#$compile(iElem)(scope);
		)


	controller: ($scope, $attrs, $state, App)->
		$scope.perfilPath = App.images+'perfil/'
		# This array keeps track of the accordion groups
		this.groups = []
		$scope.hasRoleOrPerm = AuthService.hasRoleOrPerm

		$scope.$state = $rootScope.$state
		$scope.persona_id = Perfil.User().persona_id

		if $scope.hasRoleOrPerm(['Admin', 'Profesor'])

			$http.get('::grupos').then((r)->
				$scope.grupos = r.data
			, (r2)->
				toastr.error 'No se pudo traer los grupos del menú'
			)

		ProfesoresServ.contratos().then((r)->
			$scope.profesores = r
			#$rootScope.profesores = $scope.profesores
		, (r2)->
			toastr.error 'No se pudo traer los profesores del menú'
		)

		$scope.listarAsignaturas = ()->

			modalInstance = $modal.open({
				templateUrl: '==areas/listasignaturasPop.tpl.html'
				controller: 'ListasignaturasPopCtrl'
			})
			modalInstance.result.then( (r)->
				#console.log 'Resultado del modal: ', r
			)


		$scope.irDefinitivas = (profesor_id)->
			$state.go('panel.definitivas_periodos', {profesor_id: profesor_id})


		$scope.ir_a_informes = ()->
			#$scope.$parent.bigLoader 	= true
			$state.go 'panel.informes'


		this.clikeando = ->
			#console.log 'Menu compacto', $rootScope.menucompacto

		# Ensure that all the groups in this menu are closed
		this.closeOthers = (openGroup) ->
			angular.forEach this.groups, (group) ->
				if ( group.menuIsOpen == true )
					group.menuIsOpen = false

		# This is called from the accordion-group directive to add itself to the accordion
		this.addGroup = (groupScope)->
			that = this
			this.groups.push(groupScope)

			groupScope.$on '$destroy', (event) ->
				that.removeGroup(groupScope)

		# This is called from the accordion-group directive when to remove itself
		this.removeGroup = (group) ->
			index = this.groups.indexOf(group)
			if ( index != -1 )
				this.groups.splice(index, 1)

		@



])

.directive('subMenu',[ ()->
	require: '^sidebarMenu'
	restrict: 'A'
	replace: true
	scope: true

	link: (scope, iElem, iAttrs, sidebarMenuCtrl)->
		scope.menuIsOpen = if iAttrs.menuIsOpen then scope.$eval(iAttrs.menuIsOpen) else false

		if iAttrs.hija
			if scope.menuIsOpen == true
					iElem.addClass 'open'

			scope.toggleOpen = ()->
				if scope.menuIsOpen == false
					iElem.addClass 'open'
					scope.menuIsOpen = true
				else
					iElem.removeClass 'open'
					scope.menuIsOpen = false
		else

			sidebarMenuCtrl.addGroup(scope)
			scope.$watch 'menuIsOpen', (value)->
				if value == true
					iElem.addClass 'open'
				else
					iElem.removeClass 'open'

			scope.toggleOpen = ()->
				if scope.menuIsOpen == false
					sidebarMenuCtrl.closeOthers(scope)
					scope.menuIsOpen = true
				else
					scope.menuIsOpen = false

])


.directive('myDropDown',['$document', ($document)->
	restrict: 'A'
	replace: true
	scope:true

	link: (scope, iElem, iAttrs)->
		scope.menuIsOpen = if iAttrs.menuIsOpen then scope.$eval(iAttrs.menuIsOpen) else false

		if scope.menuIsOpen == true
			iElem.addClass 'open'

		scope.toggleOpen = ()->
			if scope.menuIsOpen == true
				iElem.addClass 'open'
				scope.menuIsOpen = true
			else
				iElem.removeClass 'open'
				scope.menuIsOpen = false
			return
		return
])


.directive('stopEvent', [() ->
	restrict: 'A'
	link: (scope, element, attr) ->
		element.bind attr.stopEvent, (e)->
			e.stopPropagation()
])



.directive 'toggle', ()->
	toggleClass = 'selected'
	groups = {}

	addElement = (groupName, elem)->
		groups[groupName] = groups[groupName] || []
		if (groups[groupName].indexOf(elem) == -1)
			groups[groupName].push(elem)

	removeElement = (groupName, elem)->
		idx = (groups[groupName] or []).indexOf(elem)
		if (idx != -1)
			groups[groupName].splice(idx, 1)

	setActive=(groupName, elem)->
		angular.forEach groups[groupName] or [], (el)->
			el.removeClass(toggleClass)
		elem.addClass(toggleClass)

	restrict: 'A'
	link: (scope, elem, attrs)->
		groupName = attrs.toggle or 'default'
		addElement(groupName, elem)

		elem.on 'click', ()->
			scope.$apply ()->
				setActive(groupName, elem)

		scope.$on '$destroy', ()->
			elem.off()
			removeElement(groupName, elem)


.controller('ListasignaturasPopCtrl', ['$scope', '$uibModalInstance', '$http', 'toastr', '$state', ($scope, $modalInstance, $http, toastr, $state)->

	$scope.selectAsignatura = (asig_id, profesor_id)->
		$state.go 'panel.notas', {asignatura_id: asig_id, profesor_id: profesor_id}
		$modalInstance.close(asig_id)

	$http.get('::asignaturas/listasignaturas-alone').then((r)->
		$scope.asignaturas = r.data
	, (r2)->
		toastr.error 'No se pudo traer tus asignaturas'
	)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])


