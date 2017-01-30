/**
 * Clase generica para la definicion de la ventana para
 * la edicion de los registros de una tabla. Basicamente
 * maneja los botones e inserta la forma que manipula los registros
 * para poder exponer algunos metodos requeridos por el controller.
 *
 * Basicamnete soporta una forma principal de ediciion de datos
 * instancia de la clase isc.DynamicFormExt
 *
 * Una grilla opcional con el detalle del registro en edicion de la forma principal
 * de la clase isc.DetailGridContainer la cual a su vez podra contener una
 * forma interna para la edicion de los items.
 *
 * Asi mismo manipula mas de un tabulador si se requiere.
 *
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2016-01-26 04:56:39 -0500 (mar, 26 ene 2016) $
 * $Rev: 376 $
 */
isc.defineClass("WindowBasicFormExt", "Window");
isc.WindowBasicFormExt.addProperties({
    canDragResize: true,
    showFooter: false,
    autoSize: false,
    autoCenter: true,
    isModal: true,
    autoDraw: false,
    revertValueKey: "ctrl-z",
    /**
     * @cfg {boolean} efficientDetailGrid
     * Si es true la grilla de detalle solo se releeara cuando la llave de cabecera
     * cambie, de lo contrario se leera siempre.
     */
    efficientDetailGrid: true,
    /**
     * @cfg {boolean} useDeleteButton
     * Si la forma requiere boton de eliminacion. (Usado usualmente cuando no es creada desde una grilla)
     * yaque la grilla debe eliminar.
     */
    useDeleteButton: false,
    /**
     * @cfg {array de objetos} joinKeyFields
     * Un arreglo conteiendo las llaves de join entre la forma
     * y el grid de detalle.
     * La forma de cada elemento es : {fieldName:'nombre',fieldValue:'valoe'}
     */
    joinKeyFields: [],
    /**
     * @private
     * @property {isc.DynamicFormExt} referencia a la forma que edita registros
     */
    _form: undefined,
    /**
     * @private
     * @property {isc.HStack} referencia al agrupador de botones de la forma
     */
    _formButtons: undefined,
    /**
     * @private
     * @cfg {isc.DetailGridContainer} _detailGridContainer
     * referencia al container de la grilla de items o detalles.
     */
    _detailGridContainer: undefined,
    /**
     * @private
     * @cfg {isc.VLayout} _paneLayout
     * referencia al layout que contendra todos los elmentos de la ventana.
     */
    //  _paneLayout: undefined,
    /**
     * @private
     * @cfg {isc.TabSet} _tabSet
     * referencia al tab set  que contendra todos los elementos de la ventana,
     * por ende la forma siempre tendra al menos un tab principal.
     */
    _tabSet: undefined,
    /**
     * Retorna el tabset interno para manipulacion por el controler.
     *
     * @return {isc.TabSetExt} con el tabset.
     */
    getTabSet: function () {
        return this._tabSet;
    },
    /**
     * Metodo QUE DEBERA Sobrescribirse en el cual se
     * creara y retornara la instancia de la forma que manejara la edicion de
     * los registros.
     *
     * @param {string} formMode 'add','edit' el modo de inicio al crear.
     *
     * @return {isc.DynamicFormExt} una instancia de la forma que manejara los registro
     */
    createForm: function (formMode) {
        return undefined;
    },
    /**
     * Retorna la forma interna que maneja los datos del registro
     * en proceso.
     *
     * @return {isc.DynamicFormExt} instancia de la forma  interna que maneja los datos
     */
    getForm: function () {
        return this._form;
    },
    /**
     * Retorna la instancia del boton que efectua la funcion solicitada.
     * Actualmente soporta el de salir y el de grabar
     *
     * @param {string} btnType  'exit','save'
     * @return {isc.Button} una instancia del boton
     */
    getFormButton: function (btnType) {
        if (btnType === 'exit') {
            //return btnExit;
            return this._formButtons.getMember('btnExit' + this.ID);
        } else if (btnType === 'save') {
            //return btnSave;
            return this._formButtons.getMember('btnSave' + this.ID);
        } else if (btnType === 'delete' && this.useDeleteButton === true) {
            //return btnSave;
            return this._formButtons.getMember('btnDelete' + this.ID);
        }
        return undefined;
    },
    /**
     * Solicita a la forma se indiquue si segun el modo puede o no puede
     * mostrarse la grilla .
     *
     * @param {string} mode 'add','edit'
     */
    canShowTheDetailGrid: function (mode) {
        if (mode == 'edit') {
            return true;
        }
        return false;
    },
    /**
     * Solicita a la forma se indiquue luego de agregarse un registro la lista de detalle se muestra
     * o no , por default llama a canShowTheDetailGrid para compatibilidad con codigo anterior
     * ahora si se requiere algo especifico debe hacerse override a esta.
     *
     * @param {string} mode 'add','edit'
     */
    canShowTheDetailGridAfterAdd: function () {
        return this.canShowTheDetailGrid('add');
    },
    /**
     * Muestra la ventana de la forma colocando previamente a la DynamicFormExt
     * en el mode de edicion indicado .
     * De existir grilla de detalle la esconde o no dependiendo del modo.
     *
     * @param {string} mode 'add','edit'
     */
    showWithMode: function (mode) {
        this._form.setEditMode(mode);

        // Si existe grilla de items se muestra o nodependiendo
        // si esta permitido
        if (this._detailGridContainer !== undefined) {
            if (this.canShowTheDetailGrid(mode) == true) {
                this.showDetailGridList();
            } else {
                // Escondemos la grilla
                this.hideDetailGridList();
            }
        }
        this.show();
    },
    /**
     * Metodo QUE DEBERA Sobrescribirse en el cual se
     * creara y retornara la instancia al container de la grilla que manejara la edicion de
     * los items del registro.
     *
     * @param {string} formMode 'add','edit' el modo de inicio al crear.
     *
     * @return {isc.DetailGridContainer} una instancia al container de la grilla de items
     */
    createDetailGridContainer: function (formMode) {
        return undefined;
    },
    /**
     * Retorna la grilla de detalle  interna que maneja los items del registro
     * en proceso.
     *
     * @return {isc.ListGrid} instancia de la grilla de detalles de existri , undefined
     * de lo contrario.
     */
    getDetailGrid: function () {
        if (this._detailGridContainer !== undefined) {
            return this._detailGridContainer.getDetailGrid();
        } else {
            return undefined;
        }
    },
    /**
     * Muestra la grilla de detalles.
     */
    showDetailGridList: function () {
        // Si existe grilla de items se muestra si el modo es edit
        // de lo contrario se esconde.
        if (this._detailGridContainer !== undefined) {
            this._detailGridContainer.show();
            this._detailGridContainer.showSection(0);

            // Dado que en el caso que la grilla se mantenga via una forma interna a la sectionStack que lo contine
            //en este caso showSection(0) invocara el show del vlayout container y no el de la grilla
            // en ese caso forzamos la llamada a show a la misma grilla.
            if (this.getDetailGridForm() !== undefined) {
                this._detailGridContainer.getDetailGrid().show();
            }
            // Se reajusta el tamaño de la ventana para que soporte la aparicion de la grilla
            console.log(this.minHeight);
            console.log(this._detailGridContainer.getHeight());
            this.resizeTo(this.getWidth(), this.minHeight + this._detailGridContainer.getHeight());
        }
    },
    /**
     * Esconde la grilla de detalles.
     */
    hideDetailGridList: function () {
        // Si existe grilla de items se muestra si el modo es edit
        // de lo contrario se esconde.
        if (this._detailGridContainer !== undefined) {
            this._detailGridContainer.hide();
            this._detailGridContainer.hideSection(0);
            // Se reajusta el tamaño de la ventana para que soporte la desaparicion de la grilla
            this.resizeTo(this.getWidth(), this.minHeight);
        }
    },
    /**
     * Indica si la grilla de detalles es visible o no.
     *
     * @return {boolean} true si es visible false de lo contrario
     */
    isDetailGridListVisible: function () {
        if (this._detailGridContainer) {
            return this._detailGridContainer.isVisible();
        } else {
            return false;
        }
    },
    /**
     * Retorna el boton que controla la accion de add o refresh en los
     * datos de la grilla de items.
     * En realidad estos botones se encuentran en la cabecera del container
     * de la grilla.
     *
     * @param {string} btn nombre del boton , add o refresh
     * @return {isc.Button} instancia del boton
     */
    getDetailGridButton: function (btn) {
        if (this._detailGridContainer !== undefined) {
            return this._detailGridContainer.getButton(btn);
        } else {
            return undefined;
        }
    },
    /**
     * Si el container interno tiene una grilla con su propio form interno (no inline editor)
     * aqui se retorna la instancia de dicha forma si existe.
     * Dado que el container debe ser  DetailGridContainer para contener una forma en el
     * layout que contiene la grilla verificamos a que instancia pertenece el container
     * y de acuerdo a eso llamamos al metodo que nos devuelve la instancia de dicha forma
     * si existe.
     *
     * @return {isc.DynamicForm} instancia de la grilla de detalles de existri , undefined
     * de lo contrario.
     */
    getDetailGridForm: function () {
        if (this._detailGridContainer !== undefined &&
            this._detailGridContainer.isA(isc.DetailGridContainer)) {
            return this._detailGridContainer.getChildForm();
        }
        return undefined;
    },
    /**
     * Muestra la forma interna de edicion de items de grilla de existir,
     * asi mismo disable la forma principal y esconde los botones de la misma
     * de tal manera que no se pueda hacer edicion de nongun tipo sobre la forma
     * principal mientras se edita un registro.
     */
    detailGridFormShow: function () {
        if (this._detailGridContainer !== undefined &&
            this._detailGridContainer.isA(isc.DetailGridContainer)) {
            this._form.disable();
            this._formButtons.hide();
            this._detailGridContainer.childFormShow();
        }
    },
    /**
     * Esconde la forma interna de edicion de items de grilla de existir,
     * asi mismo re enable la forma principal y muestra sus botones correspondientes
     * de tal forma que se pueda editar sobre la forma principal.
     */
    detailGridFormHide: function () {
        if (this._detailGridContainer !== undefined &&
            this._detailGridContainer.isA(isc.DetailGridContainer)) {
            this._form.enable();
            this._formButtons.show();
            this._detailGridContainer.childFormHide();
        }
    },
    /**
     * Retorna la instancia de los botones sea de save o exit
     * @param {string} btnType puede ser 'save' o 'exit'
     *
     * @returns {isc.Button}
     */
    getDetailGridFormButton: function (btnType) {
        if (this._detailGridContainer !== undefined &&
            this._detailGridContainer.isA(isc.DetailGridContainer)) {
            return this._detailGridContainer.getGridFormButton(btnType);
        }
        return undefined;
    },
    /**
     * Cierra la forma principal pero verifica primero si hay cambios.
     * @see _close(boolean,boolean)
     */
    detailGridFormClose: function () {
        this._close(false, false);
    },
    /**
     * Metodo de bajo nivel que efectua la real accion de close a la forma.
     * Esta segun los parametros chequeara tanto si la forma principal tiene cambios
     * o la forma interior de edicion de items tiene cambios , de haberlos consultara
     * el cierre de la ventana.
     *
     * @private
     *
     * @param {boolean} checkMainForm , si es true se verificara si hay cambios en la forma principal.
     * @param {boolean} doRealClose si es true la ventana se cerrara de lo contrario la forma interna solo
     * se escondera,
     *
     */
    _close: function (checkMainForm, doRealClose) {
        console.log('//////////////////////////////////////////////////////////')
        console.log(this._form.getOldValues())
        console.log(this._form.getValues())
        console.log(this._form.getChangedValues())

        var me = this;
        var existChanges = false;

        if (this._form.valuesHaveChanged() === true && checkMainForm === true) {
            existChanges = true;
        } else {
            if (this.getDetailGridForm() !== undefined && this.getDetailGridForm().isVisible()) {
//                console.log('**********************************************************')
//                console.log(this.getDetailGridForm().getOldValues())
//                console.log(this.getDetailGridForm().getChangedValues())
                if (this.getDetailGridForm().valuesHaveChanged() === true) {
                    existChanges = true;
                }
            }
        }

        if (existChanges === true) {
            isc.ask('Desea perder sus cambios ?', function (value) {
                if (value === true) {
                    me.detailGridFormHide();
                    if (doRealClose === true) {
                        me.Super('close', arguments);
                    }
                }
            });
        } else {
            this.detailGridFormHide();
            if (doRealClose === true) {
                me.Super('close', arguments);
            }
        }


    },
    /**
     * Hook metod llamado por Smartclient al presionarse el boton de cerrar la ventana,
     * solicitara el cierre previa verificacion de cambios tanto en la forma principal
     * como en la exterior.
     *
     */
    close: function () {
        this._close(true, true);
    },
    /**
     *
     * Funcion helper que al ser invocada hara un fetch al registro del que depende un campo  x
     * de la forma a editar.
     * La ventaja de invocar este metodo es que notificara a la forma y la grilla para que
     * actualizen cmpos que podrian depender de este registo.
     *
     * IMPORTANTE : Estos campso solo deben ser selectItem o comboboxItem para otros casos no existe fetch data.
     *
     * Este metodo se invocara si se requiere:
     * Garantizar que solo cuando realmente se ha leido el registro se notifique.
     * Esto se debe a que por default al ser asincronico y autoleerse no se conoce el momento
     * en que finalmente el registro fue leido , pero durante el setup a editarse de un registro
     * otras partes de la pantalla requieren de esta informacion para mostrar,ocultar,calcular etc
     * campos dependientes.
     *
     * Importante :
     *
     * Para que esto funcione ok es necesario que campo tenga :
     *  fetchMissingValues: false,
     *  autoFetchData: false
     * De no ser asi este metodo podria obtener mas de un registro y solo devolvera el primero.solo devolvera el primer
     * registro,  por esto durante el fetch se forzara dichos valores y al terminar la operacion se repondran a su estado anterior.
     *
     * Para evitar que se lean mas de un valor desde luego se tiene la criteria la cual forzara la lectura de un unico
     * registro si esta correctamente definido, de no ser asi podra leer mas de uno y este metodo solo retornara el primer
     * registro encontrado.
     *
     * @param {string} con el nombre del campo sobre el cual se fechara su data , debe ser  comboboxes o selects.
     * @param {object} objeto json conteniendo la criteria a usar. La criteria debe tratar de obtener UN SOLO REGISTRO.
     */
    fetchFieldRecord: function (formFieldName, criteria) {
        var item = this._form.getItem(formFieldName);

        // Si implementa picklist entonces es un combo o un select.
        if (item && item.isA('isc.PickList')) {
            // Preservamos los valores de fetchMissingValues y autoFetchData
            var fetchMissingValues = item.fetchMissingValues;
            var autoFetchData = item.autoFetchData;

            item.fetchMissingValues = false;
            item.autoFetchData = false;

            // pickListCriteria puede venir definida
            var criteriaBackup = isc.clone(item.pickListCriteria);

            // Si hay criteria enviada se agrega al picklist criteria.
            if (criteria) {
                item.pickListCriteria = isc.addProperties(criteria, {"filterSearchExact": true});
            }

            var me = this;
            item.fetchData(function (it, resp, data, req) {
                var grid = me.getDetailGrid();
                var gridForm = me.getDetailGridForm();
                var record = null;

                if (resp.status >= 0) {
                    record = data[0];
                } else {
                    record = null;
                }

                // Luego de la operacion la forma,la grilla y la forma interna seran notificadas.
                me.getForm().fieldDataFetched(formFieldName, record);
                if (grid) {
                    grid.fieldDataFetched(formFieldName, record);
                }
                if (gridForm) {
                    gridForm.fieldDataFetched(formFieldName, record);
                }

                // Al terminar el fetch la criteria sera puesta en blanco.
                if (criteria) {
                    item.pickListCriteria = isc.clone(criteriaBackup);
                }
                // Restauramos los valores de fetchMissingValues y autoFetchData
                item.fetchMissingValues = fetchMissingValues;
                item.autoFetchData = autoFetchData;

            });
        } else {
            return null;
        }
    },
    /**
     *
     * Funcion a ser implementada que debe retorna el valor del campo llave para el join de los detalles ,
     * por ejemplo los items de una factura.
     *
     * @return {mixed} valor con el nombre del campo llave para el join a los detalles
     */
    /* getJoinKeyFieldName: function() {
     return this.joinKeyFieldName;
     },*/
    /**
     * Metodo que setea el valor la llave de join a los detalles del registro principal , los items de
     * una factura por ejemplo.
     *
     * @param {int} field posicion en el arreglo de join keys.
     * @param {mixed} fieldValue , valor de la llave de join a los detalles.
     * @TODO: NO FUNCIONA.
     */
    setJoinKeyFieldValue: function (field, fieldValue) {
        this.joinKeyFields[field].fieldValue = fieldValue;
    },
    /**
     * Este metodo es llamado cuando durante un edit se requiere solicitar los datos  de la grilla
     * Existen casos en que la lectura de estos datos es condicional a los datos de la cabecera , por ende aqui se da la oportunidad de indicar
     * si se requiere releer o no , por default indica que si.
     */
    isRequiredReadDetailGridData: function () {
        return true;
    },
    /**
     * Metodo llamado durante de la inicializacion de la clase
     * para si se desea agregar mas tabs a la pantalla principal
     * para esto eso debe hacerse en un override de este metodo.
     *
     * Observese que el TabSet es del tipo TabSetExt el cual soporta el metodo
     * addAditionalTab.
     *
     * Por default no hace nada
     *
     * @param isc.TabSetExt tabset El tab set principal al cual agregar.
     */
    addAdditionalTabs: function (tabset) {
    },
    /**
     * Funcion privada que observa el evento tabSelected de l TabSetExt
     * para poder modificar el tamaño de la ventana de acuerdo a lo requerido por cada
     * pane de los tabs.
     *
     * Este metodo recuerdese es que es un metodo observado por ende
     * es llamado luego de que sea normalmente requerido por el event
     * manager.
     *
     * Los parametros son los standrard del los metodos del TabSet.
     */
    _tabSelected: function (tabNum, tabPane, ID, tab, name) {
        // Como es protocolar el primer tab contiene la forma principal
        // y requiere trtamiento especial por la grilla de detalles.
        // De lo contrario si el tabPane destino esta definido cambiamos el tamaño
        // para poder contener completo el pane.
        if (tabNum == 0) {
            if (this._detailGridContainer && this._detailGridContainer.sectionIsExpanded(0) == true) {
                this.resizeTo(this.getWidth(), this.minHeight + this._detailGridContainer.getHeight());
            }
            else {
                this.resizeTo(this.getWidth(), this.minHeight);
            }
        } else {
            // Dado que tabSelected la priemra vez puede llamarse con el tabPane en null (se crea a demanda)
            // lo obtenemos a partir del tabNum.
            tabPane = this._tabSet.getTabPane(tabNum);
            if (tabPane) {
                // Esta linea ha sido modificada para no depender del contenido del tab en la posicion en cero sino
                // de las metricas de las ventanas. Existen ajustes segun el caso si el area del nuevo tab es menor o mayor que el area actual.
                // TODO: mejorar esto .
                //this.resizeTo(this.getWidth(), this.minHeight + (tabPane.getHeight() - this._tabSet.getTabPane(0).getHeight()));
                if (this.getHeight() <= tabPane.getHeight()) {
                    this.resizeTo(this.getWidth(), (tabPane.getHeight() + tabPane.getHeight() - this.getHeight() - this._tabSet.tabBar.getHeight()-10));
                } else {
                    this.resizeTo(this.getWidth(), (20+tabPane.getHeight() + this._tabSet.tabBar.getHeight()+this.header.getHeight()+(this.getHeight()-this.getInnerHeight())));
                }
            }
        }
    },
    // Inicialiamos los widgets interiores
    initWidget: function () {
        this.Super("initWidget", arguments);
        // Se setea el minimo de la ventana al valor de la alturan inicial.
        // IMPORTANTE: el valor inicial debe ser sin contar el alto de la grilla
        // ya que la misma se presentara solo en edicion o inmediatamente de grabar
        // correctamente el header.
        this.minHeight = this.getHeight();

        // Se crea la grilla de detalle (siempre que se requiera
        var detailGridContainer = this.createDetailGridContainer(this.formMode);

        if (detailGridContainer !== undefined) {
            this._detailGridContainer = detailGridContainer;
        }

        // this.getDetailGridForm();

        // Botones principales del header
        this._formButtons = isc.HStack.create({
            membersMargin: 10,
            height: 24, // width: '100%',
            layoutAlign: "center",
            padding: 5,
            autoDraw: false,
            align: 'center',
            members: [
                isc.Button.create({
                    ID: "btnExit" + this.ID,
                    width: '100',
                    autoDraw: false,
                    title: "Salir"
                }),
                isc.Button.create({
                    ID: "btnSave" + this.ID,
                    width: '100',
                    autoDraw: false,
                    title: "Grabar"
                })
            ]
        });

        if (this.useDeleteButton === true) {
            this._formButtons.addMember(isc.Button.create({
                ID: "btnDelete" + this.ID,
                width: '100',
                autoDraw: false,
                title: "Eliminar"
            }));
        }

        // LA funcion createForm debe sobrescribirse por la clase
        // que extiende a esta.
        this._form = this.createForm(this.formMode);
        this._form.align = 'center';

        this._tabSet = isc.TabSetExt.create({ID: "ts" + this.ID});
        this._tabSet.createFormTab(this._form, this._detailGridContainer, this._formButtons);
        this.addItem(this._tabSet);
        this.addAdditionalTabs(this._tabSet);

        // Para poder variar el tamaño de la ventana segun la necesidad de contenido de cada tab.
        this.observe(this._tabSet, "tabSelected", "observer._tabSelected(tabNum, tabPane, ID, tab, name);");

        // Inicializamos visualmente, eso es por si hay grilla de detalles
        // la cual ocultaremos o mostraremos segun el modo.
        this.showWithMode(this.formMode);
    }
})
;
