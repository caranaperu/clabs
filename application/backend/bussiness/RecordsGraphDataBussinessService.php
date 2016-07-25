<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que obtiene la informacion necearia para graficar los resultados
 * de los los records de una prueba y categoria especifica.
 *
 * @author $Author: aranape $
 * @since 17-May-2013
 * @version $Id: RecordsGraphDataBussinessService.php 339 2014-12-03 06:55:05Z aranape $
 * @history 1.01 , Se agrego soporte para foreign key
 *
 * $Date: 2014-12-03 01:55:05 -0500 (mié, 03 dic 2014) $
 * $Rev: 339 $
 */
class RecordsGraphDataBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("RecordsGraphDAO", "", "");
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
