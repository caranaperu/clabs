/**
 * Interfase que define el API requerido para todo control que contendra una grilla y un toolbar
 * que seran la pantalla de seleccion para entrar a una pantalla de edicion.
 * El DefaultController espera que su mainWindow implemente esta interfase.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2016-01-24 17:08:51 -0500 (dom, 24 ene 2016) $
 * $Rev: 360 $
 */
isc.ClassFactory.defineInterface("IControlledCanvas");

isc.IControlledCanvas.addInterfaceProperties({
    /**
     * @private
     * @property {isc.ToolStrip} referencia a la barra de herramientas
     */
    _toolStrip: undefined,
    /**
     * @private
     * @property {isc.ListGrid} referencia a la grilla que lista los registros
     */
    _gridList: undefined,
    /**
     * @public
     * Metodo a ser llamado por el controlador luego de que en la forma de mantenimiento
     * se agregue o se haga un update en la forma principal de edicion , NO ES LLAMADA
     * por cambios en la grilla de detalle de dicha forma , en ese caso es llamada
     * afterFormDetailGridRecordSaved
     *
     * Aqui el canvas principal puede tomar decisiones basado en eso.
     *
     * @param object newValues record con los elementos grabados , actualizados o eliminados.
     * @param object oldValues record con los elementos previos a los cambios , en caso de add
     * son null..
     *
     */
    afterFormRecordSaved: function(newValues, oldValues) {
        // Debehacerse override , por default no hace nada.
    },
    /**
     * @public
     * Metodo a ser llamado por el controlador luego de que en la forma de mantenimiento
     * se haga un add o update en algun registro de la grilla de detalle de existir alguna.
     *
     * Aqui el canvas principal puede tomar decisiones basado en eso.
     *
     * @param object newValues record con los elementos grabados , actualizados o eliminados.
     * @param object oldValues record con los elementos previos a los cambios , en caso de add
     * son null..
     *
     */
    afterFormDetailGridRecordSaved: function(newValues, oldValues) {
        // Debehacerse override , por default no hace nada.
    },
    /**
     * @public
     * Este metodo es llamado po el controlador para el caso que la forma
     * requiera algunos campos o valores de este controlled canvas.
     * Debera hacerse el override de ser necesario.
     *
     * @param string mode un string con llos odos sea edit o add.
     */
    getRequiredFieldsToAddOrEdit: function(mode) {
        return undefined;
    },
    /**
     * Este metodo debera ser usado por las clases que implementen esta interfase
     * para crear la grilla , ya que este metodo inicializa _gridList para uso
     * posterior.
     *
     * @protected
     * @return {isc.GridList} con la instancia de grilla que el controlador
     * manipulara.
     */
    _createGridList: function() {
        this._gridList = this.createGridList();
        return this._gridList;
    },
    /**
     * Metodo QUE DEBERA Sobrescribirse en el cual se
     * creara y retornara la instancia de la grilla que listara
     * los registros.
     *
     * @return {isc.GridList} una instancia de la grilla con la lista de los registros
     */
    createGridList: function() {
        return undefined;
    },
    /**
     * Metodo que retorna la instancia ya creada de la grilla
     * con la lista de los registros a trabajar.
     *
     * @return {isc.GridList} una instancia de la grilla con la lista de los registros
     */
    getGridList: function() {
        return this._gridList;
    },
    /**
     * Retorna la instancia del control que efectua la funcion solicitada
     * en la toolbar.
     *
     * @param {string} btnType  'edit','add','del','refresh','print',
     *  'printPDF','printXLS'
     *
     * @return {isc.ToolStripButton} una instancia del boton
     * de la barra de herramientas de la forma.
     */
    getToolbarControl: function(btnType) {
        if (btnType === 'edit') {
            return this._toolStrip.getMember('btnEditRecord' + this.ID);
        } else if (btnType === 'add') {
            return this._toolStrip.getMember('btnNewRecord' + this.ID);
        } else if (btnType === 'del') {
            return this._toolStrip.getMember('btnDelRecord' + this.ID);
        } else if (btnType === 'refresh') {
            return this._toolStrip.getMember('btnRefreshRecord' + this.ID);
        } else if (btnType === 'print') {
            return this._toolStrip.getMember('btnPrintReport' + this.ID);
        } else if (btnType === 'printPDF') {
            return this._toolStrip.getMember('btnPrintReport' + this.ID).menu.data[0];
        } else if (btnType === 'printXLS') {
            return this._toolStrip.getMember('btnPrintReport' + this.ID).menu.data[1];
        }
        return undefined;
    },
    /**
     * Este metodo DEBERA ser usado por las clases que implementen esta interfase
     * para crear el ToolBar , ya que este metodo inicializa _toolStrip para uso
     * posterior.
     *
     * @protected
     * @return {isc.ToolStrip} con la instancia del ToolStrip creado.
     */
    _createToolStrip: function() {
        this._toolStrip = this.createToolStrip();
        return this._toolStrip;
    },
    /**
     * Este metodo puede ser sobreescrito por l clase que impelenta esta
     * interfase pero al menos debe tener o soportar los botones indicados
     * mas abajo.
     *
     * Implementacion default de el ToolStrip conteniendo los botones
     * requeridos.
     * Este ToolStrip por default contiene botonoes para :
     * Nuevo Registro.
     * Eliminar Registro.
     * Editar Registro.
     * Boton de imprimir.
     * Boton de refrescar lista.
     *
     * @return {isc.ToolStrip} con la instancia del ToolStrip creado.
     */
    createToolStrip: function() {
        // Se crea el toolbar default
        return isc.ToolStrip.create({
            autoSize: true,
            width: "100%", height: "22", padding: 2,
            colSpan: 2,
            members: [
                isc.ToolStripButton.create({
                    ID: "btnNewRecord" + this.ID,
                    icon: "../assets/images/add.png",
                    prompt: "Agregar"
                }),
                isc.ToolStripButton.create({
                    ID: "btnEditRecord" + this.ID,
                    icon: "../assets/images/edit.png",
                    prompt: "Editar"
                }), isc.ToolStripButton.create({
                    ID: "btnDelRecord" + this.ID,
                    icon: "../assets/images/delete.png",
                    prompt: "Eliminar"
                }), "separator",
                isc.IconMenuButton.create({
                    ID: "btnPrintReport" + this.ID,
                    title: "",
                    icon: "../assets/images/print.png",
                    menu: {
                        autoDraw: false,
                        defaultWidth: 10,
                        showKeys: false,
                        data: [
                            // TRUCO : si no se define la funcion click dicho metodo no puede ser observado
                            // ya que no existe implementacion default y solo es invocado si el metodo esta definido.
                            {title: "PDF", keyTitle: "", icon: "../assets/images/pdf.png", click: function() {
                                }},
                            {title: "XLS", keyTitle: "", icon: "../assets/images/xls.png", click: function() {
                                }}
                        ]
                    }
                }), "separator",
                isc.ToolStripButton.create({
                    ID: "btnRefreshRecord" + this.ID,
                    icon: "../assets/images/refresh.png",
                    prompt: "Actualizar Lista"
                })]
        });
        //return this._toolStrip;
    }
});
