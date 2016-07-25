<?php
/**
 * Define la implementacion default de un Bussiness Service
 * para los metodos menos usados.
 *
 *
 * @author Carlos Arana Reategui
 * @version 1.00 , 03 AGO 2011
 *
 * @since 1.00
 */
abstract class TSLStandardBussinessService extends TSLBussinessService {

     protected function validateData(TSLIDataTransferObj $dto) {
         return TRUE;
     }

     protected function preExecuteService($action,TSLIDataTransferObj $dto){
     }

     protected function postExecuteService($action,TSLIDataTransferObj $dto){
     }

}

?>
