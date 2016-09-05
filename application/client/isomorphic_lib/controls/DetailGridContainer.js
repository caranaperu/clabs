/**
 * Clase generica que define un container y su respectiva grilla
 * la cual seran usadas en las formas para manipular los items de un registro ,
 * por ejemplo los items de una factura.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-05-13 12:47:55 -0500 (mar, 13 may 2014) $
 * $Rev: 182 $
 */
isc.defineClass("DetailGridContainer", "SectionStack");
isc.DetailGridContainer.addProperties({
    autoSize: false,
    autoDraw: false,
    align: 'center',
    overflow: "hidden",
    /**
     * @private
     * @cfg {string} sectionTitle
     * Titulo que tendra la cabecera del container de la grilla de items
     */
    sectionTitle: '',
    /**
     * @private
     * No debe manipularse externamente usar el getter
     * @property {isc.ListGrid} referencia a la grilla interna de items
     */
    _detailGrid: undefined,
    /**
     * @private
     * No debe manipularse externamente usar el getter
     * @property {isc.DynamicForm} referencia al form para editar la lineas de grillado
     */
    _childForm: undefined,
     /**
     * @private
     * No debe manipularse externamente , sin uso externo
     * @property {isc.VLayout} referencia al layout que contiene la grilla y su propio form para
     * editar las lineas de esta.
     */
    _gridLayout: undefined,
     /**
     * @private
     * No debe manipularse externamente
     * @property {isc.HStack} referencia al container de los botones para la forma
     * dentro de la grilla para la edicion de sus registros
     * editar las lineas de esta.
     */
    _gridFormButtons: undefined,
    /**
     * @public
     * Metodo helper el cual debe ser overloaded  para la creacion de la forma que editara o agregara
     * registros a la grilla.
     *
     *
     * @return {isc.DynamicForm} instancia a usarse para editar los items.
     */
    getFormComponent: function () {
        return undefined;
    },
    /**
     * Retorna la instancia de la interna a la forma que agrega o modifica registros de la grilla.
     *
     * @return {isc.DynamicForm} instancia en uso para editar los items.
     */
    getChildForm: function () {
        return this._childForm;
    },
    /**
     * Muestra la forma que agrega o modifica registros de la grilla.
     * Ademas pone en disabled la grilla para evitar se manipule la misma
     * mientras se edita o grega registros a la misma a traves de la forma.
     */
    childFormShow: function () {
        if (this._gridLayout !== undefined) {
            this._detailGrid.disable();
            this._gridLayout.getMember(1).show();
            this.adjustForContent(true);
        }
    },
    /**
     * Esconde la forma que agrega o modifica registros de la grilla.
     * Ademas pone en enbled la grilla para permitir moverse a traves de la misma.
     */
    childFormHide: function () {
        if (this._gridLayout !== undefined) {
            this._detailGrid.enable();
            this._gridLayout.getMember(1).hide();
        }
    },
    /**
     * Metodo hook llamado desde el container de la forma cuando un termina el fetch de un registro
     * para un campo determinado campo de la forma, esta sera llamada solo si se invoca
     * fetchFieldRecord en el container.
     * Esto sera util cuando se requiera manipular algunos campos que son necesarios pero dependen
     * de que un determinado registro de un campo este previamente cargado, dado que el ajax es asincronico
     * este metodo garantiza que sera invocado cuando realmente el registro este leido.
     *
     * @param {String} nombre del campo en la forma principal  del cual depende esta grilla.
     * @param {object} que representa el registro leido o null si no existe registro.
     *
     */
    fieldDataFetched: function(formFieldName,record) {
        return;
    },
    /**
     * @private
     * Metodo helper de uso interno para la creacion de la grilla interna para el manejo
     * de los items.
     *
     * @param {object} properties propiedades en formato json de la grilla interna
     * basicamente los campos y el datasource son suficientes.
     *
     * @return {isc.ListGrid} instancia de la grilla para los items
     */
    _createGrid: function (properties) {
        var defProperties = {
            autoDraw: false,
            selectionType: 'single',
            canRemoveRecords: true,
            warnOnRemoval: true,
            /**
            * Metodo hook llamado desde el container de la forma cuando un termina el fetch de un registro
            * para un campo determinado campo de la forma, esta sera llamada solo si se invoca
            * fetchFieldRecord en el container.
            * Esto sera util cuando se requiera manipular algunos campos que son necesarios pero dependen
            * de que un determinado registro de un campo este previamente cargado, dado que el ajax es asincronico
            * este metodo garantiza que sera invocado cuando realmente el registro este leido.
            *
            * @param {String} nombre del campo en esta forma.
            * @param {object} que representa el registro leido o null si no existe registro.
            *
            */
           fieldDataFetched: function(formFieldName,record) {
               return;
           },
           /**
            * Metodo hook llamado desde el controlador cada vez que un item en la forma principal
            * es cambiado , aqui podra tomarse decisiones por ejemplo de cambiar la visibilidad
            * de campos en la grilla que depena de un determinado valor de la forma principal.
            *
            * @param {FormItem} item este tambien puede ser un combobox
            * @param {any} newValue
            * @returns true , SIEMPRE DEBE RETORNA TRUE
            */
           mainFormItemChanged: function(item,newValue) {
               return true;
           }
                //  editEvent: 'click',
                // Esta propiedad es propia , si es false no agregara nuevos items.
                // Util para los casos de treegrid donde no se agrega directamente
                // canAdd: true
        };
        var fullProperties = isc.addProperties(defProperties, properties);
        if (properties.gridType === undefined) {
            this._detailGrid = isc.ListGrid.create(fullProperties);
        } else {
            this._detailGrid = isc.TreeGrid.create(fullProperties);
        }
        return this._detailGrid;

    },
    /**
     * Retorna la instancia de la grilla interna que manipula los items
     *
     * @return {isc.ListGrid} instancia de la grilla de items.
     */
    getDetailGrid: function () {
        return this._detailGrid;
    },
    /**
     * Retorna la instancia de los botones que manipulan el agregar a los items
     * o refrescar la lista que contiene la grilla de items.
     * Basicamente es usada por el controller.
     *
     * @param {string} btn los valores aceptados son 'add' y 'refresh'
     * @return {isc.Button} instancia del boton.
     */
    getButton: function (btn) {
        if (btn === 'add') {
            return this.sections[0].controls[0];
        } else if (btn === 'refresh') {
            return this.sections[0].controls[1];
        }
        return undefined;
    },
    /**
     * Retorna la instancia de los botones que manipulan el agregar a los items
     * o cancelar la accion , son usados basicamente desde el controlador.
     *
     * @param {string} btn los valores aceptados son 'save' y 'exit'
     * @return {isc.Button} instancia del boton.
     */
    getGridFormButton: function (btn) {
        if (btn === 'save') {
            return this._gridFormButtons.members[1];
        } else if (btn === 'exit') {
            return this._gridFormButtons.members[0];
        }
        return undefined;
    },
    initWidget: function () {
        this.Super("initWidget", arguments);

        var abtn = isc.ImgButton.create({
            ID: "addButton" + this.ID,
            autoDraw: false,
            src: "[SKIN]actions/add.png", size: 16,
            showFocused: false, showRollOver: false, showDown: false
        });


        var rbtn = isc.ImgButton.create({
            ID: "refreshButton" + this.ID,
            autoDraw: false,
            src: "[SKIN]actions/refresh.png", size: 16,
            showFocused: false, showRollOver: false, showDown: false
        });

        // Agregamos la seccion
        this.addSection({title: this.sectionTitle, expanded: true,canCollapse: false, controls: [abtn, rbtn]});

        var grid = this._createGrid(arguments[0].gridProperties);

        this._childForm = this.getFormComponent();

        if (this._childForm !== undefined) {
            var me = this;
            // Botones principales del header
            this._gridFormButtons = isc.HStack.create({
                membersMargin: 10,
                height: 24, // width: '100%',
                layoutAlign: "center", padding: 5, autoDraw: false,
                align: 'center',
                members: [isc.Button.create({
                        ID: "btnExit" + me.ID,
                        width: '100',
                        autoDraw: false,
                        title: "Salir"
                    }),
                    isc.Button.create({
                        ID: "btnSave" + me.ID,
                        width: '100',
                        autoDraw: false,
                        title: "Grabar"
                    })
                ]
            });
            this._childForm.saveButton = this._gridFormButtons.members[1];

            this._gridLayout = isc.VLayout.create({members: [
                    grid,
                    isc.VLayout.create({
                        visibility: "hidden",
                        members: [this._childForm,this._gridFormButtons]
                    })
                ],
                defaultLayoutAlign: "center",
                styleName:"tabButtonTopSelected"});

            // agregamos la grilla a la seccion
            this.addItem(0, this._gridLayout, 0);
        } else {
            // Preparamos los atributos default requeridos
            grid.canAdd= true;
            grid.canEdit= true;
            grid.waitForSave= true;
            grid.validateByCell= true;
            grid.stopOnErrors= true;
            grid.modalEditing= true;
            grid.rowEndEditAction= "same";
            grid.enterKeyEditAction= "nextCell";

            this.addItem(0,grid,0);
        }

        // Iniciamos en forma no visible , se encendera segun el modo sea agregar
        // o editar.
        this.hide();
    }
});