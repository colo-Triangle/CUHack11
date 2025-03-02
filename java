package org.example.chaincode;

import org.hyperledger.fabric.shim.ChaincodeBase;
import org.hyperledger.fabric.shim.ChaincodeStub;
import org.hyperledger.fabric.shim.Chaincode.Response;
import org.hyperledger.fabric.shim.Chaincode.Response.Status;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;

public class PrivateDataChaincode extends ChaincodeBase {

    @Override
    public Response init(ChaincodeStub stub) {
        return newSuccessResponse("Chaincode instantiated successfully");
    }

    @Override
    public Response invoke(ChaincodeStub stub) {
        String function = stub.getFunction();
        if ("storeJSON".equals(function)) {
            return storeJSON(stub);
        }
        return newErrorResponse("Invalid function name: " + function, Status.INTERNAL_SERVER_ERROR);
    }

    // This function now expects the JSON file path as the first parameter.
    private Response storeJSON(ChaincodeStub stub) {
        List<String> params = stub.getParameters();
        if (params.size() < 1) {
            return newErrorResponse("Missing parameter: JSON file path", Status.INTERNAL_SERVER_ERROR);
        }
        String filePath = params.get(0);
        try {
            byte[] jsonData = Files.readAllBytes(Paths.get(filePath));
            // "myPrivateCollection" must be defined in your collection configuration.
            // "jsonKey" is the key under which the JSON file is stored.
            stub.putPrivateData("myPrivateCollection", "jsonKey", jsonData);
            return newSuccessResponse("JSON stored successfully");
        } catch (IOException e) {
            return newErrorResponse("Error reading file: " + e.getMessage(), Status.INTERNAL_SERVER_ERROR);
        }
    }

    public static void main(String[] args) {
        new PrivateDataChaincode().start(args);
    }
}
