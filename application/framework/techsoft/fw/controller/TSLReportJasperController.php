<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

require_once(dirname(__FILE__) . '/../libs/TSLClientJasperLib.php');

/**
 * Controlador especifico para el backend JasperREports , basado en comunicacion SOAP
 * este generara un archivo de reporte final para su posterior download
 * por parte del browser.
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: TSLReportJasperController.php 4 2014-02-11 03:31:42Z aranape $
 * @history ''
 *
 * $Date: 2014-02-10 22:31:42 -0500 (lun, 10 feb 2014) $
 * $Rev: 4 $
 */
abstract class TSLReportJasperController extends TSLReportController {

    public function __construct() {
        parent::__construct();
    }

    /**
     * Genera el reporte de salida en un directorio temporal el cual
     * debera ser accesible por el servidor web.
     *
     * @param mixed $contents binario,texto, etc con la salida final del reporte
     * @return mixed string con el filename del reporte o FALSE si hubo un error
     */
    protected function createReportOutputFile(&$contents) {
        $dr = $this->getTmpOutputDirectory();
        $tn = tempnam($dr, 'RP_');
        //$tn .= '.pdf';
        $answer = FALSE;

        $fh = @fopen($tn, 'w');
        if ($fh !== FALSE) {
            if (@fwrite($fh, $contents) !== FALSE) {
                if (@fclose($fh) !== FALSE) {
                    $answer = '/tmp/' . basename($tn);
                }
            }
        }

        return $answer;
    }

    /**
     * Metodo de ayuda para emitir los errores al lado cliente , para el caso
     * del jasper simplemente se indicara un error 500 y un mensaje de error
     * en texto , el cual podra ser usado para visualizarlo en el browser o
     * lado cliente.
     *
     * @param string $error el error a pintar.
     */
    protected function outputError($error) {
        $protocol = (isset($_SERVER['SERVER_PROTOCOL']) ? $_SERVER['SERVER_PROTOCOL'] : 'HTTP/1.0');
        header($protocol . ' 500 Internal Server Error');
        echo (strlen($error) > 0 ? $error : 'Error no conocido...');
    }

    /**
     * Rutina principal de entrada .
     *
     * @param type $reportServerUser
     * @param type $reportServerPassword
     * @param type $formatOutput
     */
    protected function executeReport($reportServerUser, $reportServerPassword, $formatOutput) {
        try {

            // recogemos los que seran parametros del reporte y los parseamos
            // para generar el formato requerido.
            $input_params = &$this->getInputReportParamsList();
            $report_params = &$this->getReportParams($input_params);

            // El formato de salida del reporte.
            $output_params = array();
            $output_params[RUN_OUTPUT_FORMAT] = $formatOutput;

            // ejecutamos el reporte , via SOAP.
            $currentUri = $this->getReportURI();
            $result = ws_runReport($reportServerUser, $reportServerPassword, $currentUri, $report_params, $output_params, $attachments);

            // verficamos si el reporte pudo ser ejecutado.
            if (is_soap_fault($result)) {
                $errorMessage = $result->getFault()->faultstring;
                $this->outputError(strlen($errorMessage) > 0 ? $errorMessage : 'Reporte no procesado , error en proceso');
                die();
            }


            // Verificamos si el reporte fue ejecutado este fue exitoso.
            $operationResult = getOperationResult($result);

            if ($operationResult['returnCode'] != '0') {
                $msg = 'Error executing the report:<br><font color="red">' . $operationResult['returnMessage'] . '</font>';
                $this->outputError($msg);
                die();
            }

            // si el reporte tiene attachments (en jasper es la manera de emitir)
            // segun el formato se imprime, solo soportamos PDF y XLS.
            if (is_array($attachments)) {
                $contents = $attachments["cid:report"];
                if ($output_params[RUN_OUTPUT_FORMAT] == RUN_OUTPUT_FORMAT_PDF) {
                    header("Content-type: application/pdf");

                    $answer = $this->createReportOutputFile($contents);
                    if ($answer === FALSE) {
                        $this->outputError('Error grabando archivo de salida...');
                    } else {
                        echo $answer;
                    }
                    // readfile($tn);
                    //print_r(array_keys($attachments));
                } else if ($output_params[RUN_OUTPUT_FORMAT] == RUN_OUTPUT_FORMAT_XLS) {
                    header('Content-type: application/xls');
                    header('Cache-Control: must-revalidate');
                    header('Pragma: public');
                    header('Content-Description: File Transfer');
                    header('Content-Disposition: attachment; filename="reportxxx.xls"');

                    $answer = $this->createReportOutputFile($contents);
                    if ($answer === FALSE) {
                        $this->outputError('Error grabando archivo de salida...');
                    } else {
                        echo $answer;
                    }

//                    readfile($tn);
                }

                //  die();
            } else {
                $this->outputError('No se encontro contenido del reporte...');
            }
        } catch (Exception $ex) {
            $this->outputError($ex->getMessage());
        }
    }

    /**
     * Debera retornar un arreglo simple con la lista de nombres
     * de los parametros que deberan usarse para el reporte.
     *
     * @return array Lista de parametros
     */
    abstract protected function &getInputReportParamsList();
}
