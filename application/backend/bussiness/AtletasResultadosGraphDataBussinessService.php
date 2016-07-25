<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que obtiene la informacion necearia para graficar los resultados
 * de los atletas de diversas maneras, basicamente solo usa fetch de datos.
 *
 * @author $Author: aranape $
 * @since 17-May-2013
 * @version $Id: AtletasResultadosGraphDataBussinessService.php 222 2014-06-23 23:01:24Z aranape $
 * @history 1.01 , Se agrego soporte para foreign key
 *
 * $Date: 2014-06-23 18:01:24 -0500 (lun, 23 jun 2014) $
 * $Rev: 222 $
 */
class AtletasResultadosGraphDataBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("AtletasResultadosGraphDAO", "", "");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return AtletasResultadosModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) {
        return NULL;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return EntrenadoresAtletasModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) {
        return NULL;
    }

    /**
     *
     * @return AtletasResultadosModel
     */
    protected function &getEmptyModel() {
        $model = new \app\common\model\TSLAppCommonBaseModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) {
        return NULL;
    }

}

?>
