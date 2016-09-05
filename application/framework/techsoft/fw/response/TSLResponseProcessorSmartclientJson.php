<?php

/**
 * Clase que implemente el JSON encoding para el DTO, ESTE ES EL DEFAULT
 * sino se implementa ninguno en especial
 *
 * @author Carlos Arana Reategui
 * @version 1.00 , 15 JUN 2011
 *          1.01 , 15 Mayo 2013 , se hace que siempre los errores se devuelvan como
 *                  arreglo para facilitar el trabajo del cliente
 *
 * @since 1.00
 *
 */
class TSLResponseProcessorSmartclientJson implements TSLIResponseProcessor {

    /**
     * Genera la salida en JSON.
     *
     * @param TSLIDataTransferObj con el Data Transfer Object a procesar
     * @return un String con el DTO en formato JSON
     */
    public function &process(TSLIDataTransferObj &$DTO) {
        $out = NULL;
        if (isset($DTO)) {
            /* @var $outMessage TSLOutMessage */
            $outMessage = &$DTO->getOutMessage();


            if (strlen($outMessage->getAnswerMesage()) > 0) {
                // STATUS_OK = 0
                $out = 'status:-1';
                $out .= ',data:"' . $outMessage->getAnswerMesage() . '- Cod.Error: ' . $outMessage->getErrorCode() . '"';
            }

            if ($outMessage->isSuccess() == FALSE) {

                if ($outMessage->hasFieldErrors()) {
                    // VALIDATION ERRORS
                    $out = 'status:"-4"';
                    $fldErrors = &$outMessage->getFieldErrors();

                    // Si ya tiene longitud , ponemos una coma para indicar
                    // un nuevo elemento.
                    if (isset($out) and strlen($out) > 0) {
                        $out .= ',';
                    }

                    // la lista de field errors.
                    $out .= '"errors":{';
                    $count = count($fldErrors);

                    for ($i = 0; $i < $count; $i++) {
                        $out .= $fldErrors[$i]->getField() . ':"' . $fldErrors[$i]->getErrorMessage() . '"';
                        if ($i < $count - 1) {
                            $out .= ',';
                        }
                    }
                    $out .= '}';
                } else if ($outMessage->hasProcessErrors()) {
                    // STATUS_FAILURE = -1
                    $out = 'status:-1';

                    $processErrors = &$outMessage->getProcessErrors();
                    // Si ya tiene longitud , ponemos una coma para indicar
                    // un nuevo elemento.
                    if (isset($out) and strlen($out) > 0) {
                        $out .= ',';
                    }

                    // la lista de process errors.
                    $out .= 'data:';
                    $count = count($processErrors);

                    for ($i = 0; $i < $count; $i++) {
                        if ($i > 0) {
                            $out .= '\n';
                        }
                        $out .= '"';

                        $perr = str_replace(array("\"", "\r", "\n", "\r\n"), ' ', $processErrors[$i]->getErrorMessage());
                        // Si tiene excepcion procesamos.
                        $ex = $processErrors[$i]->getException();
                        if (isset($ex)) {
                            if (isset($perr)) {
                                $out .= $perr . ' - ' . str_replace(array("\"", "\r", "\n", "\r\n"), ' ', $ex->getMessage()) . ' ** CodError = ' . $processErrors[$i]->getErrorCode();
                            } else {
                                $out .= str_replace(array("\"", "\r", "\n", "\r\n"), ' ', $ex->getMessage()) . ' ** CodError =' . $processErrors[$i]->getErrorCode();
                            }
                        } else {
                            $out .= $perr . ' ** CodError =' . $processErrors[$i]->getErrorCode();
                        }

                        $out .= '"';
                        if ($i < $count - 1) {
                            $out .= ',';
                        }
                    }
                    $out .= '';
                }
            } else {
                // STATUS_OK = 0
                $out = 'status:0';
            }
            // Si tiene parametros de salida los agregamos  antres de la data.
            $outParams = &$outMessage->getOutputparameters();
            if (is_array($outParams)) {
                foreach ($outParams as $i => $value) {
                    $out .= ',' . $i . ':' . $value;
                }
            }

            // Si no hay errores de proceso evaluamos la data
            if ($outMessage->hasProcessErrors() == FALSE && strlen($outMessage->getAnswerMesage()) == 0) {
                $oneRecord = false;
                // Procesamos la data
                $data = $outMessage->getResultData();


                if (isset($data)) {
                    // Si no es un arreglo solo posee un registro
                    if (!is_array($data)) {
                        $oneRecord = true;
                    }

                    $out .= ',data:';

                    $dataResults = $outMessage->getResultData();
                    $this->_processExtraData($dataResults);
                //    $dataResults = TSLUtilsHelper::array_ut8_encode_recursive($outMessage->getResultData());
                    $out .= json_encode($dataResults);

                    // Numero de registros = al numero de registros leidos + la posicion inicial en el set
                    // siempre que haya mas de una respuesta
                    $constraints = &$DTO->getConstraints();
                    if ($oneRecord === FALSE) {
                        $numRecords = $constraints->getStartRow() + count($dataResults);
                    } else {
                        $numRecords = 1;
                    }
                    // SE hace de tal forma que si no es el ultimo registro osea numRecords es menor a la ultima fila solicitada
                    // Ponemos como el total de registros una pagina mas (esto para evitar hacer un count)
                    $out .= ',endRow : "' . $numRecords . '"';
                    $out .= ',totalRows: "' . ( ($numRecords < $constraints->getEndRow() || $constraints->getEndRow() == 0) ? ($numRecords) : $constraints->getEndRow() + ($constraints->getEndRow() - $constraints->getStartRow())) . '"';
                    //                   $out .= ',totalRows: "'. ( $numRecords < 1000 ? ($numRecords)  :  1000 + (1000 - $constraints->getStartRow())) .'"';
                } else {
                    if ($out == NULL) {
                        // STATUS_OK = 0
                        $out = 'status:-1';
                        $out .= ',data:"Error Desconocido"';
                    }
                }
            }

            $out = '{response:{' . $out . '}}';
            return $out;
        } else {
            $out = '?????????????????';
            return $out;
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