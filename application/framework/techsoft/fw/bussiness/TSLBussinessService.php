<?php
/**
 * Clase abstract que implementa la logica de un Servicio
 * de Negocio.
 *
 * @author carana
 */
abstract class TSLBussinessService implements TSLIBussinessService {

    public function executeService($action, TSLIDataTransferObj $dto) {
        if ($this->validateData($dto) === TRUE) {
            $this->preExecuteService($action, $dto);
            $this->doService($action, $dto);
            $this->postExecuteService($action, $dto);
        }
    }

    abstract protected function validateData(TSLIDataTransferObj $dto);
    abstract protected function preExecuteService($action,TSLIDataTransferObj $dto);
    abstract protected function doService($action,TSLIDataTransferObj $dto);
    abstract protected function postExecuteService($action,TSLIDataTransferObj $dto);

}

?>
