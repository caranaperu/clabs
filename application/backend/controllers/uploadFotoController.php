<?php

/**
 * Controlador simple para cargar imagenes al servidor , el mismo otorga un nombre unico a la
 * imagen , por ahora no verifica si existe o no para proceder a la eliminacion. Queda
 * para la siguiente version.
 *
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: uploadFotoController.php 318 2014-07-30 04:38:27Z aranape $
 * @history ''
 *
 * $Date: 2014-07-29 23:38:27 -0500 (mar, 29 jul 2014) $
 * $Rev: 318 $
 */
class uploadFotoController extends app\common\controller\TSLAppDefaultController {

    /**
     * El Data transfer Object
     * @var TSLIDataTransferObj
     */
    protected $DTO;

    function __construct() {
        parent::__construct();
        $this->load->helper(array('form', 'url'));
    }

    function index() {
        $this->do_upload();
    }

    function do_upload() {
        // Setup
        $config['upload_path'] = APPPATH . '../photos/';
        $config['allowed_types'] = 'gif|jpg|png|jpeg';
        $config['max_size'] = '400';
        $config['max_width'] = '1024';
        $config['max_height'] = '1024';
        $config['encrypt_name'] = TRUE;


        $this->load->library('upload', $config);
        // El campo tipo file a enviarse
        $field_name = "selectedImageFile";

        // Lo cargo y actuo segun el error.
        if (!$this->upload->do_upload($field_name)) {
            $error = array('error' => $this->upload->display_errors());
            $outMessage = &$this->DTO->getOutMessage();

            $error['error'] = strip_tags($error['error']);
            $processError = new TSLProcessErrorMessage(80000, $error['error'], null);
            $outMessage->addProcessError($processError);
        } else {
            $data = array('imageUrl' => '../../photos/' . $this->upload->data()['file_name']);

            $this->DTO->getOutMessage()->setSuccess(true);
            $this->DTO->getOutMessage()->setResultData($data);
        }
        $data['data'] = &$this->responseProcessor->process($this->DTO);
        $this->load->view($this->getView(), $data);
    }

}

?>