angular.module('myvcFrontApp')

.directive('sidebarMenu',['App', '$rootScope', 'AuthService', 'Restangular', '$modal', 'Perfil', (App, $rootScope, AuthService, Restangular, $modal, Perfil)-> 

	restrict: 'E'
	replace: true
	templateUrl: "#{App.views}directives/sidebarMenu.tpl.html"
	scope: 
		cargando: "="

	link: (scope, iElem, iAttrs)->
		# Debo agregar la clase .loading-inactive para que desaparezca el loader de la pantalla.
		# y eso lo puedo hacer con el ng-if
	controller: ($scope, $attrs)->
		# This array keeps track of the accordion groups
		this.groups = []
		$scope.hasRoleOrPerm = AuthService.hasRoleOrPerm

		$scope.$state = $rootScope.$state
		$scope.persona_id = Perfil.User().persona_id

		if $scope.hasRoleOrPerm(['Admin', 'Profesor'])

			Restangular.all('grupos').getList().then((r)->
				$scope.grupos = r
			, (r2)->
				console.log 'No se pudo traer los grupos: ', r2
			)

		Restangular.all('contratos').getList().then((r)->
			$scope.profesores = r
		, (r2)->
			console.log 'No se pudo traer los profesores: ', r2
		)

		$scope.listarAsignaturas = ()->

			modalInstance = $modal.open({
				templateUrl: App.views + 'areas/listasignaturasPop.tpl.html'
				controller: 'ListasignaturasPopCtrl'
			})
			modalInstance.result.then( (r)->
				console.log 'Resultado del modal: ', r
			)


		this.clikeando = ->
			console.log 'Menu compacto', $rootScope.menucompacto

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
				console.log 'Valor de scope.menuIsOpen: ', scope.menuIsOpen
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
			if scope.menuIsOpen == false
				iElem.addClass 'open'
				scope.menuIsOpen = true
				###
				iElem.bind 'click', (event)->
					event.stopPropagation()
					console.log 'Previne la propagación'
				###
				$document.bind 'click', (event)->
					isClickedElementChildOfPopup = iElem.find(event.target).length > 0;
					if (isClickedElementChildOfPopup)

						###
						console.log 'iAttrs.evitarCierre', $(event.target).parents(iAttrs.evitarCierre).length==1
						hasParent = $(event.target).parents(iAttrs.evitarCierre)
						if iAttrs.evitarCierre
							if hasParent.length==1
								scope.menuIsOpen = false
								iElem.removeClass 'open'
								scope.$apply()
							console.log 'Tiene el evitar!'
						###
						return

					

					scope.menuIsOpen = false
					iElem.removeClass 'open'
					scope.$apply()
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


.controller('ListasignaturasPopCtrl', ['$scope', '$modalInstance', 'Restangular', 'toastr', '$state', 'Perfil', ($scope, $modalInstance, Restangular, toastr, $state, Perfil)->
	
	$scope.selectAsignatura = (asig_id)->
		console.log asig_id
		$state.go 'panel.notas', {asignatura_id: asig_id}
		$modalInstance.close(asig_id)

	Restangular.all('asignaturas/listasignaturas').getList().then((r)->
		$scope.asignaturas = r
	, (r2)->
		console.log 'No se pudo traer tus asignaturas, ', r2
	)

	$scope.cancel = ()->
		$modalInstance.dismiss('cancel')

])


