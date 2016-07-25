<?php

/**
 * Clase que implemente el JSON encoding para el DTO
 *
 * @author Carlos Arana Reategui
 * @version 1.00 , 15 JUN 2011
 *          1.01 , 15 Mayo 2013 , se hace que siempre los errores se devuelvan como
 *                  arreglo para facilitar el trabajo del cliente
 *
 * @since 1.00
 * @todo ELIMINAR AHORA ES UN OUTPUT PROCESSOR
 *
 */
class TSLDTOEnconderJSON implements TSLIDTOEnconder {

    /**
     * Genera la salida en JSON.
     *
     * @param TSLIDataTransferObj con el Data Transfer Object a procesar
     * @return un String con el DTO en formato JSON
     */
    public function encode(TSLIDataTransferObj $DTO) {
        if (isset($DTO)) {
            /* @var $outMessage TSLOutMessage */
            $outMessage = &$DTO->getOutMessage();

            $out = 'success:' . ($outMessage->isSuccess() == FALSE ? '"false"' : '"true"');

            if (strlen($outMessage->getAnswerMesage()) > 0) {
                $out .= ',"am":[{"msg": "' . $outMessage->getAnswerMesage() . '","ce":"' . $outMessage->getErrorCode() . '"}]';
            }

            if ($outMessage->isSuccess() == FALSE) {

                if ($outMessage->hasFieldErrors()) {
                    $fldErrors = &$outMessage->getFieldErrors();

                    // Si ya tiene longitud , ponemos una coma para indicar
                    // un nuevo elemento.
                    if (isset($out) and strlen($out) > 0)
                        $out .= ',';

                    // la lista de field errors.
                    $out .= '"errors":{';
                    $count = count($fldErrors);

                    for ($i = 0; $i < $count; $i++) {
                        $out .= $fldErrors[$i]->getField() . ':"' . $fldErrors[$i]->getErrorMessage() . '"';
                        if ($i < $count - 1)
                            $out .= ',';
                    }
                    $out .= '}';
                } else if ($outMessage->hasProcessErrors()) {

                    $processErrors = &$outMessage->getProcessErrors();
                    // Si ya tiene longitud , ponemos una coma para indicar
                    // un nuevo elemento.
                    if (isset($out) and strlen($out) > 0)
                        $out .= ',';

                    // la lista de process errors.
                    $out .= '"pe":[';
                    $count = count($processErrors);

                    for ($i = 0; $i < $count; $i++) {
                        $perr = str_replace(array("\"","\r","\n","\r\n"), ' ',$processErrors[$i]->getErrorMessage());
                        // Si tiene excepcion procesamos.
                        $ex = $processErrors[$i]->getException();
                        if (isset($ex)) {
                            if (isset($perr)) {
                                $out .= '{"msg":"' . $perr . ' - ' . str_replace(array("\"","\r","\n","\r\n"), ' ',$ex->getMessage()) . '","ce":"' . $processErrors[$i]->getErrorCode() . '"';
                            } else {
                                $out .= '{"msg":"' . str_replace(array("\"","\r","\n","\r\n"), ' ',$ex->getMessage()) . '","ce":"' . $processErrors[$i]->getErrorCode() . '"';
                            }
                        } else {
                            $out .= '{"msg":"' .$perr . '","ce":"' . $processErrors[$i]->getErrorCode() . '"';
                        }

                        $out .= '}';
                        if ($i < $count - 1)
                            $out .= ',';
                    }
                    $out .= ']';
                }
            }
            // Si tiene parametros de salida los agregamos  antres de la data.
            $outParams = &$outMessage->getOutputparameters();
            if (is_array($outParams)) {
                foreach ($outParams as $i => $value) {
                    $out .= ',' . $i . ':' . $value;
                }
            }

            // Procesamos la data
            $data = $outMessage->getResultData();
            if (isset($data)) {
                $out .= ',data:';
                $this->_processExtraData($outMessage->getResultData());
                $out .= json_encode(TSLUtilsHelper::array_ut8_encode_recursive($outMessage->getResultData()));
            }

            return '{' . $out . '}';
        } else {
            return '?????????????????';
        }
    }

    protected function _processExtraData(&$p_extdata) {
        if (isset($p_extdata)) {
            $extdata = $p_extdata;
            // IF not an array
            if (!is_array($p_extdata)) {
                // if is an object
                if (is_object($p_extdata)) {
                    if ($p_extdata instanceof TSLDataModel) {
                        $p_extdata = $extdata->getAsArray();
                    } else {
                        $p_extdata = (array) $extdata;
                    }
                }
            }
        }
    }

}

?>