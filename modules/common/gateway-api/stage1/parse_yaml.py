import yaml
import json
import sys

def process_yaml(file_path):
    processed_documents = {}
    with open(file_path, 'r') as file:
        documents = list(yaml.safe_load_all(file))
        for i, doc in enumerate(documents):  # Skip the first document
            if 'status' in doc:
                del doc['status']
            # Key by a unique identifier, like a combination of name and kind
            key = f"{doc.get('metadata', {}).get('name', 'unknown')}-{doc.get('kind', 'unknown')}"
            processed_documents[key] = yaml.dump(doc)

    print(json.dumps(processed_documents))

if __name__ == "__main__":
    yaml_file = sys.argv[1]
    process_yaml(yaml_file)
