<?php

/**
 * Clase que implemente el JSON encoding para el la salida para AmCharts para las solicitudes
 * que requieran los daos de los resultados de los atletas , para efectos graficos.
 * Puede contener una o mas series con los resultados , por ahora soportahasta 5 series
 * simultaneas.
 * Ejemplo de la salida JSON esperada.
 * En el caso de errores sera de la misma manera que el caso del procesador del SmartClient,
 *
 *   var x = {
 *       response: {
 *           status: 0,
 *           seriesTitles: ["Arana Chiesa, Melissa", "Montes Xxxxxx, Romina"],
 *           prueba: "100 Metros con Vallas",
 *           um: "SEG",
 *           seriesData: [
 *               [
 *                   {
 *                       lugar: "Grand Prix Brigido Iriarte / Barinas / Venezuela",
 *                       comentario: "MAY-MAY( V:2.00 )",
 *                       fecha: "2013-05-10",
 *                       tresultado: "14.56",
 *                       nresultado: 14.56,
 *                       tipo: "RS",
 *                       vflag: " ",
 *                       manual: "f"
 *                   },
 *                   {
 *                       lugar: "Bolivarianos 2013 / Trujillo / Peru",
 *                       comentario: "Heptatlon/MAY-MAY( V:2.10 / Manual )",
 *                       fecha: "2013-12-12",
 *                       tresultado: "12.44",
 *                       nresultado: 12.44,
 *                       tipo: "RS",
 *                       vflag: "*",
 *                       manual: "t"
 *                   }
 *               ],
 *               [
 *                   {
 *                       lugar: "Grand Prix Brigido Iriarte / Barinas / Venezuela",
 *                       comentario: "MAY-MAY( V:2.00 )",
 *                       fecha: "2013-05-10",
 *                       tresultado: "12.33",
 *                       nresultado: 12.33,
 *                       tipo: "RS",
 *                       vflag: " ",
 *                       manual: "f"
 *                   }
 *               ]
 *           ]
 *       }
 *   }
 *
 *
 *
 * @author Carlos Arana Reategui
 * @version 1.00, 15 JUN 2011
 * 1.01, 15 Mayo 2013, se hace que siempre los errores se devuelvan como
 * arreglo para facilitar el trabajo del cliente
 *
 * @since 1.00
 *
 */
class ResponseProcessorRecordsAmchartsJson implements TSLIResponseProcessor {

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
                $out .= ',error:"' . $outMessage->getAnswerMesage() . '- Cod.Error: ' . $outMessage->getErrorCode() . '"';
            }

            if ($outMessage->isSuccess() == FALSE) {

                if ($outMessage->hasProcessErrors()) {
// STATUS_FAILURE = -1
                    $out = 'status:-1';

                    $processErrors = &$outMessage->getProcessErrors();
// Si ya tiene longitud , ponemos una coma para indicar
// un nuevo elemento.
                    if (isset($out) and strlen($out) > 0) {
                        $out .= ',';
                    }

// la lista de process errors.
                    $out .= 'error:';
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

// Si no hay errores de proceso evaluamos la data
            if ($outMessage->hasProcessErrors() == FALSE && strlen($outMessage->getAnswerMesage()) == 0) {
// Procesamos la data
                $data = $outMessage->getResultData();

                if (isset($data)) {

                    $prefixArray = '[';
                    $count = 0;
                    $out .= ',seriesTitles:[';
                    foreach ($data as $row) {
                        if ($count == 0) {
                            $out .= '"' . $row['records_tipo_descripcion'];
                            $out .= '"]';
                            $out .= ',prueba:"' . $data[0]['apppruebas_descripcion'] . '"';
                            $out .= ',um:"' . $data[0]['unidad_medida_codigo'] . '"';
                            $out .= ',seriesData:[';
                        }

                        $count++;

                        $out .= $prefixArray . '{atleta:"' . $row['atletas_nombre_completo'] . '",';
                        $out .= 'lugar:"' . $row['lugar'] . '",';
                        $out .= 'comentario:"' . $row['comentario'] . '",';
                        $out .= 'fecha:"' . $row['competencias_pruebas_fecha'] . '",';
                        $out .= 'tresultado:"' . $row['norm_resultado'] . '",';
                        $out .= 'nresultado: ' . $row['numb_resultado'] . ',';
                        $out .= 'manual:"' . $row['competencias_pruebas_manual'] . '",';
                        $out .= 'altura:"' . $row['ciudades_altura'] . '"}';
                        $prefixArray = ',';
                    }
                    if ($count > 0) {
                        $out .= ']]';
                    } else {
                        $out .= ']';
                    }
                } else {
                    if ($out == NULL) {
// STATUS_OK = 0
                        $out = 'status:-1';
                        $out .= ',error:"Error Desconocido"';
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

}

?>