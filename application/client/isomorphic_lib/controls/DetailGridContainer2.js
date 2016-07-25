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
isc.defineClass("DetailGridContainer2", "SectionStack");
isc.DetailGridContainer2.addProperties({
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
     * @property {isc.isc.ListGrid} referencia a la grilla interna de items
     */
    _detailGrid: undefined,
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
    _createGrid: function(properties) {
        var defProperties = {
            canEdit: true,
            autoDraw: false,
            waitForSave: true,
            validateByCell: true,
            stopOnErrors: true,
            selectionType: 'single',
            modalEditing: true,
            rowEndEditAction: "same",
            enterKeyEditAction: "nextCell",
            canRemoveRecords: true,
            warnOnRemoval: true,
            //  editEvent: 'click',
            // Esta propiedad es propia , si es false no agregara nuevos items.
            // Util para los casos de treegrid donde no se agrega directamente
            canAdd: true
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
    getDetailGrid: function() {
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
    getButton: function(btn) {
        if (btn === 'add') {
            return this.sections[0].controls[0];
        } else if (btn === 'refresh') {
            return this.sections[0].controls[1];
        }
        return undefined;
    },
    initWidget: function() {
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
        this.addSection({title: this.sectionTitle, expanded: true, controls: [abtn, rbtn]});
        // agregamos la grilla a la seccion
        this.addItem(0, this._createGrid(arguments[0].gridProperties), 0);
        // Iniciamos en forma no visible , se encendera segun el modo sea agregar
        // o editar.
        this.hide();
    }
});