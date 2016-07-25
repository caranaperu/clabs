<?php

/**
 * Interfase que define lo s minimos requerimientos a implementar
 * para un servicio de la aplicacion.
 *
 * @author Carlos Arana Reategui
 * @version 1.00 , 22 JUN 2011
 *
 * @since 1.00
 *
 */

interface TSLIBussinessService {

    /**
     * Punto de entrada del servicio donde se indicara la accion a tomar y asi mismo
     * los datos requeridos por dicha accion seran enviados a traves
     * del DTO.
     *
     * Todo servicio debera poner sus respuestas en la parte de mensaje de DTO
     * y debera indicar con true o false si la accion se ha ejecutado
     * con exito.
     *
     * @param string $action , nombre que identifica la accion a ejecutar.
     * @param TSLIDataTransferObj $dto , el Data transfer Object que contendra
     * todo lo necesario para la ejecucion de la accion.
     *
     */
    function executeService($action, TSLIDataTransferObj $dto);

}

?>
