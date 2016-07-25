<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas a las validaciones de categorias
 *  tales como listar , agregar , eliminar , etc.
 *
 * @author $Author: aranape $
 * @since 17-May-2013
 * @version $Id: AppCategoriasBussinessService.php 68 2014-03-09 10:19:20Z aranape $
 * @history 1.01 , Se agrego soporte para foreign key
 *
 * $Date: 2014-03-09 05:19:20 -0500 (dom, 09 mar 2014) $
 * $Rev: 68 $
 */
class AppCategoriasBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("AppCategoriasDAO", "appcategorias", "msg_appcategorias");
    }

    /**
     * No USADA
     * @param \TSLIDataTransferObj $dto
     * @return AppCategoriasModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) {
        $model = new AppCategoriasModel();
        return $model;
    }

    /**
     * NO USADA
     * @param \TSLIDataTransferObj $dto
     * @return AppCategoriasModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) {
        $model = new AppCategoriasModel();
        return $model;
    }

    /**
     *
     * @return AppCategoriasModel
     */
    protected function &getEmptyModel() {
        $model = new AppCategoriasModel();
        return $model;
    }

    /**
     * NO USADA.
     * 
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) {
        $model = new AppCategoriasModel();
        return $model;
    }

}

?>
