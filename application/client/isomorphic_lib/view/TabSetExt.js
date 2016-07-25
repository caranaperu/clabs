/**
 * Clase base para el soporte del tabset de la ventana de mantenimiento la cual soportara
 * un primer tab con la forma de mantenimiento (Siempre debe ser el primer tab)
 * y luego tabs adicionales los cuales dependeran de la data contenida en el primer tab.
 *
 * Cuando los tabs auxiliares sean creados , la ventana contenedora tendra o guardara las
 * llaves o campos de enlace entre los datos del mantenimiento y los tabs auxiliares, Para esto
 * se usa un campo prototype llamado infoKey , de acuerdo a las necesidades el manejo de esta
 * llave sera mejorada.
 *
 * La clase contenedora de los  tab  adicionales puede ser cualquier tipo , hlayout,vlayout , form ,
 * etc por ende en vez de definir una clase base , se espera que la funcionalidad de sincronizacion de
 * los datos entre la forma de mantenimiento y los tabs adicionales se haga sobre los contenedores que tengan
 * lo diguiente :
 *
 * 1) infoKey
 * 2) onInfoKeyChanged
 * 3) getInfoMember
 *
 * El primero es un miembro que guardara la ultima llave o valor de campo usado para actualizar su contenido
 * este es creado automaticamente al crearse el tab por esta clase , este definido o no.
 *
 * El segundo es un metodo que sera invocado cuando la llave de actualizacion de datos sea modificada.
 *
 * EL tercero es el que indica que pane es el que debera ser llamado para fechar los datos cada vez que la llave cambie.
 *
 * Si estos getInfoMember no existe no sera actaulizada la data cuando la llave requerida cambie , en este caso se
 * asumira que el contenido del tab adicional no requiere dicha informacion.
 *
 *
 *
 * Asi mismo cada tab de que define una pantalla adicional debera tener como minimo 3 campos
 * no documentados en el SmartClient propios de los requerimientos de esta clase.
 *
 * 1) El ID
 * 2) paneClass con el nombre de la clase del elemento visual contenedor de la vista que ira dentro del tab.
 * 3) joinField el cual contiene el nombre del campo de enlace requerido para mostrar la informacion
 * a partir de la ventana de mantenimiento.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-24 00:40:35 -0500 (mar, 24 jun 2014) $
 * $Rev: 231 $
 */
isc.defineClass("TabSetExt", "TabSet");
isc.TabSetExt.addProperties({
    autoDraw: false,
    /**
     * @cfg {array} _addtionalTabs
     */
    _addtionalTabs: [],
    /**
     * Metodo a ser llamado luego de la creacion del TabSet , este creara el primer tab
     * el que contendra el tab con el mantenimiento.
     * Los 3 elementos enviados en el parametro seran puestos dentro del primer tab.
     *
     * @param DynamicFormExt mantForm o container de la forma que contiene el formato
     * de mantenimiento de los datos.
     *
     * @param Object objeto visual el cuanl debe contenr la grilla de datos de detalle de la forma
     * principal.
     *
     * @param Object objecto visual que contendra los botones de la forma.
     */
    createFormTab: function(mantForm, detailGridContainer, buttons) {
        var pane;
        // Agregamos las partes creando el pane completo  luego lo agregamos
        // al tab set.
        if (detailGridContainer !== undefined) {
            pane = isc.VLayout.create({
                autoDraw: false,
                members: [mantForm, detailGridContainer, buttons]
            });
        } else {
            pane = isc.VLayout.create({
                autoDraw: false,
                members: [mantForm, buttons]
            });
        }
        this.addTab({pane: pane, title: 'Mantenimiento', });
    },
    /**
     * Metodo llamado por la ventana contenedora de este tabset si se desea agragar
     * nuevos tabs mas alla del tab principal que corresponde a los mantenimientos, el cual
     * siempre sera el primero.
     * Este metodo solo agregara tabs , PERO NO CREARA LA INSTANCIA DEL PANE DEL TAB HASTA
     * QUE SEA REQUERIDO POR PRIMERA VEZ A TRAVES DE TabSelected,
     *
     * Se requiere que el parametro tab se envie siempre el ID y y el nombre
     * de la clase que servira para crear el pane interior. Puede contener otras propiedades
     * que corresponden a la creacion de un tab PERO NO LA PROPIEDAD pane , ya que no sera tomada en
     * cuenta.
     *
     *
     * @param Object tab Con la definicion del taba a agregar de acuerdo a lo indicado en la documentacion
     * de este metodo..
     */
    addAdditionalTab: function(tab) {
        if (tab.paneClass == undefined || tab.ID == undefined || tab.joinField === undefined) {
            isc.say('addAditionalTabs : Se requiere el pane ClassName ,el ID y el joinField para agregar el nuevo tab');
        } else {
            if (!this._addtionalTabs.contains(tab.ID)) {
                // pane no debe estar definido se creara al requerirse por primera vez.
                tab.pane = undefined;
                this.addTab(tab);
                // Guardamos el id del tab a crear luego.
                this._addtionalTabs.push(tab.ID);
            } else {
                isc.say('addAditionalTabs : Ya contienen un tab con el ID : ' + tab.ID);
            }

        }
    },
    /**
     * Ese metodo intercepta un mensaje standard del TabSet con la intencion
     * de verificar si la forma esta lista y no tiene nada pendiente para poder abrir un tab adicional,
     * esto ya que se supone que los tabs adicionales dependen de los datos del tab principal
     * que contiene la forma de mantenimiento.
     */
    tabDeselected: function(tabNum, tabPane, ID, tab, newTab) {
        // El tab destino es un tab adicional?
        if (this._addtionalTabs.contains(newTab.ID)) {
            // Si la forma no esta lista no permitimos cambiar de tab.
            var mantForm = this.getTab(0).pane.getMember(0);
            if (mantForm.valuesHaveChanged() == true || mantForm.isNewRecord()) {
                isc.say('Debe grabar lo editado para ver informacion');
                return false;
            }
        }
        return true;
    },
    /**
     * Este metodo intercepta un mensaje standard del TabSet con la intencion
     * de crear diferidamente y solo cuando es requerido el pane adicional.
     *
     * Si el pane ya esta creado simplemente leemos la data siempre que haya habido cambios en la llave que relaciona
     * la data de la forma con la que requiere el tab a mostrar.
     */
    tabSelected: function(tabNum, tabPane, ID, tab, name) {
        if (tabPane == null && this._addtionalTabs.contains(ID)) {
            var mantForm = this.getTab(0).pane.getMember(0);
            var infoKey = Class.evaluate("MANTFORM.getValues()." + this.getTab(ID).joinField, {MANTFORM: mantForm});

            // Creamos el tab pane basado en su class name inicialaizandolo con la llave de enlace.
            var newTabPane = isc.Class.evaluate('isc.' + this.getTab(ID).paneClass + '.create({infoKey: "' + infoKey + '"});');
            this.updateTab(ID, newTabPane);
            // Si on info key existe , lo invocamos.
            if (typeof (newTabPane.onInfoKeyChanged) !== 'undefined' && typeof (newTabPane.onInfoKeyChanged) === 'function') {
                newTabPane.onInfoKeyChanged(mantForm.getValues());
            }
        } else {
            // Es un tab adicional?
            if (this._addtionalTabs.contains(ID)) {
                var mantForm = this.getTab(0).pane.getMember(0);
                var newInfoKey = Class.evaluate("MANTFORM.getValues()." + tab.joinField, {MANTFORM: mantForm});
                if (newInfoKey != tabPane.infoKey) {
                    tabPane.infoKey = newInfoKey;

                    // Verifica que el pane soporte el metodo getInfoMember , de lo contrario no hace nada..
                    if (typeof (tabPane.getInfoMember) !== 'undefined' && typeof (tabPane.getInfoMember) === 'function') {
                        // Leemos la data requerida por el pane para actualizarse.
                        tabPane.getInfoMember(name).fetchData(isc.Class.evaluate("filter={\"" + tab.joinField + "\":\"" + newInfoKey + "\"}"));

                        // Si el pane interior de este tab posee el metodo onInfoKeyChanged invocamos el metodo
                        // para dar oprtunidad de limpiar o actualizar otras vistas que dependen del member 0 que es el que esta
                        // clase actualiza directamente la data.
                        if (typeof (tabPane.onInfoKeyChanged) !== 'undefined' && typeof (tabPane.onInfoKeyChanged) === 'function') {
                            tabPane.onInfoKeyChanged(mantForm.getValues());
                        }
                    }
                }
            }
        }
    },
    // Inicialiamos los widgets interiores
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});
